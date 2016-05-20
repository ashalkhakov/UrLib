signature Types = sig
    type tunit = transaction unit
    type acceptor t = t -> tunit
    con compose = K1 ==> K2 ==> K3 ==>
     fn (f :: K2 -> K3) (g :: K1 -> K2) (x :: K1) => f (g x)
    con forget = K ==> fn (t :: K) => ()
    con equal :: K --> K -> K -> Type
    type void
end

include Types

val id : t ::: Type -> t -> t

val on : a ::: Type -> b ::: Type -> c ::: Type
         -> (b -> b -> c) -> (a -> b) -> a -> a -> c

val zip : a ::: Type -> b ::: Type -> c ::: Type
          -> (a -> b -> c) -> list a -> list b -> list c

val refl : K --> a ::: K -> equal a a

val castL : K --> a ::: K -> b ::: K
            -> equal a b -> f :: (K -> Type) -> f b -> f a
val castR : K --> a ::: K -> b ::: K
            -> equal a b -> f :: (K -> Type) -> f a -> f b

val contradiction : t ::: Type -> void -> t

val impossible : t ::: Type -> string -> t

structure Functor : sig
    class t :: (Type -> Type) -> Type
    val mk : f ::: (Type -> Type)
             -> (a ::: Type -> b ::: Type -> (a -> b) -> f a -> f b)
             -> t f
    val mp : f ::: (Type -> Type) -> t f ->
             a ::: Type -> b ::: Type -> (a -> b) -> f a -> f b
    val monad : f ::: (Type -> Type) -> monad f -> t f
    val list : t list
    val field : nm :: Name -> ts ::: {Type} -> [[nm] ~ ts]
                => t (fn t => $([nm = t] ++ ts))
    val choice : nm :: Name -> ts ::: {Type} -> [[nm] ~ ts] => folder ts
                 -> t (fn t => variant ([nm = t] ++ ts))
    val compose : f ::: (Type -> Type) -> g ::: (Type -> Type)
                  -> t f -> t g -> t (compose f g)
end

val identity_monad : monad (fn t => t)

val bit : bool -> int

val maximum : t ::: Type -> ord t -> t -> list t -> t
val minimum : t ::: Type -> ord t -> t -> list t -> t

val proj : nm :: Name -> t ::: Type -> drop ::: {Type} -> [[nm] ~ drop]
           => $([nm = t] ++ drop) -> t

val proj1 : nm ::: Name -> t ::: Type -> {nm : t} -> t

val projs : keep ::: {Type} -> drop ::: {Type} -> [keep ~ drop]
            => $(keep ++ drop) -> $keep

val rename : nm1 :: Name -> nm2 :: Name -> t ::: Type -> ts ::: {Type}
             -> [[nm1] ~ ts] => [[nm2] ~ ts]
             => $([nm1 = t] ++ ts) -> $([nm2 = t] ++ ts)

val curry : have ::: {Type} -> need ::: {Type} -> t ::: Type -> [have ~ need]
            => ($(have ++ need) -> t) -> $have -> $need -> t

val snoc : ts ::: {Type} -> $ts
           -> nm :: Name -> t ::: Type -> [[nm] ~ ts]
           => t -> $([nm = t] ++ ts)

val spawnListener : t ::: Type -> (t -> tunit) -> channel t -> tunit

val xempty : ctx ::: {Unit} -> xml ctx [] []

val xdyn : ctx ::: {Unit} -> [[Dyn] ~ ctx]
           => signal (xml ([Dyn] ++ ctx) [] []) -> (xml ([Dyn] ++ ctx) [] [])

val xactive : transaction xbody -> xbody

val mapiPartial : a ::: Type -> b ::: Type
                  -> (int -> a -> option b) -> list a -> list b

val mapNm0 : K --> tf :: ({K} -> K -> Type)
             -> r ::: {K} -> folder r
             -> (others :: {K} -> nm :: Name -> t ::: K
                 -> [[nm] ~ others] => folder others
                 -> equal r ([nm = t] ++ others)
                 -> tf ([nm = t] ++ others) t)
             -> $(map (tf r) r)

val mapNm : K --> tf1 :: (K -> Type) -> tf2 :: ({K} -> K -> Type)
            -> r ::: {K} -> folder r
            -> (others :: {K} -> nm :: Name -> t ::: K
                -> [[nm] ~ others] => folder others
                -> equal r ([nm = t] ++ others)
                -> tf1 t -> tf2 ([nm = t] ++ others) t)
            -> $(map tf1 r) -> $(map (tf2 r) r)

val cases : ts ::: {Type} -> u ::: Type
            -> $(map (fn t => t -> u) ts) -> variant ts -> u

val casesGet : K --> r ::: {K} -> folder r -> t ::: Type
               -> variant (map (fn _ => t) r) -> t

val casesFunctor : r ::: {Type} -> folder r
                   -> f ::: (Type -> Type) -> Functor.t f
                   -> variant (map f r) -> f (variant r)

val casesMap : K --> tf1 :: (K -> Type) -> tf2 :: (K -> Type)
               -> r ::: {K} -> folder r
               -> $(map (fn t :: K => tf1 t -> tf2 t) r)
               -> variant (map tf1 r) -> variant (map tf2 r)

val casesMapU : K --> tf1 :: (K -> Type) -> tf2 :: (K -> Type)
                -> r ::: {K} -> folder r
                -> (t ::: K -> tf1 t -> tf2 t)
                -> variant (map tf1 r) -> variant (map tf2 r)

val casesTraverse : K --> tf1 :: (K -> Type) -> tf2 :: (K -> Type)
                    -> r ::: {K} -> folder r
                    -> f ::: (Type -> Type) -> Functor.t f
                    -> $(map (fn t :: K => tf1 t -> f (tf2 t)) r)
                    -> variant (map tf1 r) -> f (variant (map tf2 r))

val casesDiag : K --> tf1 :: (K -> Type) -> tf2 :: (K -> Type)
                -> tf3 :: (K -> Type)
                -> r ::: {K} -> folder r
                -> $(map (fn t :: K => tf1 t -> tf2 t -> tf3 t) r)
                -> variant (map tf1 r) -> variant (map tf2 r)
                -> option (variant (map tf3 r))

val casesDiagU : K --> tf1 :: (K -> Type) -> tf2 :: (K -> Type)
                 -> tf3 :: (K -> Type)
                 -> r ::: {K} -> folder r
                 -> (t ::: K -> tf1 t -> tf2 t -> tf3 t)
                 -> variant (map tf1 r) -> variant (map tf2 r)
                 -> option (variant (map tf3 r))

val casesDiagTraverse : K --> tf1 :: (K -> Type) -> tf2 :: (K -> Type)
                        -> tf3 :: (K -> Type)
                        -> r ::: {K} -> folder r
                        -> f ::: (Type -> Type) -> monad f
                        -> $(map (fn t :: K => tf1 t -> tf2 t -> f (tf3 t)) r)
                        -> variant (map tf1 r) -> variant (map tf2 r)
                        -> f (option (variant (map tf3 r)))
