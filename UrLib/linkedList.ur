open Prelude

datatype llSignals a =
    SglNil
  | SglCons of {Carq : signal (option a), Cdr : signal (llSignals a)}

con signals a = signal (llSignals a)

fun mp [a] [b] (f : a -> b) =
    let
        fun goLl ll =
            case ll of
                SglNil => SglNil
              | SglCons cons =>
                SglCons {Carq = Monad.mp (Option.mp f) cons.Carq,
                         Cdr = goSgl cons.Cdr}
        and goSgl sgl = Monad.mp goLl sgl
    in
        goSgl
    end

fun foldl [a] [b] (f : a -> b -> b) (z : b) =
    let
        fun goLl ll =
            case ll of
                SglNil => return z
              | SglCons cons =>
                carq <- cons.Carq;
                cdr <- goSgl cons.Cdr;
                return (case carq of
                            None => cdr
                          | Some car => (f car cdr))
        and goSgl sgl = bind sgl goLl
    in
        goSgl
    end

fun mapX [a] [ctx] [[Dyn] ~ ctx] (f : a -> xml ([Dyn] ++ ctx) [] []) =
    let
        fun goLl ll =
            case ll of
                SglNil => xempty
              | SglCons cons => <xml>
                {xdyn (Monad.mp (compose (Option.get xempty)
                                         (Option.mp f))
                                cons.Carq)}
                {goSgl cons.Cdr}
              </xml>
              and goSgl sgl = xdyn (Monad.mp goLl sgl)
    in
        goSgl
    end

datatype llSources a =
    SrcNil
  | SrcCons of {Carq : source (option a), Cdr : source (llSources a)}

con sources a =
    {First : source (llSources a),
     Last : source (source (llSources a))}

fun mk [a] (exec : (a -> tunit) -> tunit)
    : transaction (sources a) =
    first <- source SrcNil;
    last <- source first;
    let
        fun go (x : a) =
            carq <- source (Some x);
            nil <- source SrcNil;
            cons <- get last;
            set cons (SrcCons {Carq = carq, Cdr = nil});
            set last nil
    in
        exec go;
        return {First = first, Last = last}
    end

fun value [a] (srcs : sources a) : signals a =
    let
        fun goLl ll =
            case ll of
                SrcNil => SglNil
              | SrcCons cons =>
                SglCons {Carq = signal cons.Carq, Cdr = goSrc cons.Cdr}
        and goSrc src = Monad.mp goLl (signal src)
    in
        goSrc srcs.First
    end

fun insert [a] (x : a) (srcs : sources a) =
    (* Last should always point to SrcNil, but in case it somehow points to a
       SrcCons, this inserts in the middle rather than dropping the end. *)
    cdr <- bind (bind (get srcs.Last) get) source;
    carq <- source (Some x);
    lastNew <- source (SrcCons {Carq = carq, Cdr = cdr});
    set srcs.Last lastNew

fun iterPred [a] (f : source (option a) -> tunit) (p : a -> bool)
    : sources a -> tunit =
    let
        fun goLl ll =
            case ll of
                SrcNil => return ()
              | SrcCons cons =>
                carq <- get cons.Carq;
                (case carq of
                     None => return ()
                   | Some car =>
                     if p car then
                         f cons.Carq
                     else
                         return ());
                goSrc cons.Cdr
        and goSrc src = bind (get src) goLl
    in
        compose goSrc (proj [#First])
    end

fun update [a] (f : a -> a) =
    iterPred (fn src => bind (get src) (compose (set src) (Option.mp f)))

val delete = fn [a] => iterPred (fn src => set src None)
