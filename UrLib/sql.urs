include Prelude.Types

val sqlInjectRow :
    tables ::: {{Type}} -> agg ::: {{Type}} -> exps ::: {Type} ->
    fields ::: {Type} ->
    folder fields -> $(map sql_injectable fields) ->
    $fields
    -> $(map (sql_exp tables agg exps) fields)

val insert :
    fields ::: {Type} -> uniques ::: {{Unit}} ->
    folder fields -> $(map sql_injectable fields) ->
    sql_table fields uniques ->
    $fields
    -> tunit

val update :
    unchanged ::: {Type} -> uniques ::: {{Unit}} ->
    changed ::: {Type} -> [changed ~ unchanged] =>
    folder changed -> $(map sql_injectable changed) ->
    sql_table (changed ++ unchanged) uniques ->
    sql_exp [T = changed ++ unchanged] [] [] bool ->
    $changed
    -> tunit

val delete :
    fields ::: {Type} -> uniques ::: {{Unit}} ->
    sql_table fields uniques ->
    sql_exp [T = fields] [] [] bool
    -> tunit

val select :
    vals ::: {Type} -> others ::: {Type} -> [vals ~ others] =>
    tabl ::: Type -> fieldsOf tabl (vals ++ others) ->
    tabl ->
    sql_exp [T = vals ++ others] [] [] bool
    -> sql_query [] [] [T = vals] []

val lookup :
    tabs ::: {{Type}} -> agg ::: {{Type}} -> exps ::: {Type} ->
    tab ::: Name -> keys ::: {Type} -> others ::: {Type} ->
    [keys ~ others] => [[tab] ~ tabs] =>
    folder keys -> $(map sql_injectable keys) ->
    $keys
    -> sql_exp ([tab = keys ++ others] ++ tabs) agg exps bool

val lookups :
    tabs ::: {{Type}} -> agg ::: {{Type}} -> exps ::: {Type} ->
    tab ::: Name -> keys ::: {Type} -> others ::: {Type} ->
    [keys ~ others] => [[tab] ~ tabs] =>
    folder keys -> $(map sql_injectable keys) ->
    list $keys
    -> sql_exp ([tab = keys ++ others] ++ tabs) agg exps bool

val selectLookup :
    keys ::: {Type} -> vals ::: {Type} -> others ::: {Type} ->
    [keys ~ vals] => [keys ~ others] => [vals ~ others] =>
    folder keys -> $(map sql_injectable keys) ->
    tabl ::: Type -> fieldsOf tabl (keys ++ vals ++ others) ->
    tabl ->
    $keys
    -> sql_query [] [] [T = vals] []

val selectLookups :
    keys ::: {Type} -> vals ::: {Type} -> others ::: {Type} ->
    [keys ~ vals] => [keys ~ others] => [vals ~ others] =>
    folder keys -> $(map sql_injectable keys) ->
    tabl ::: Type -> fieldsOf tabl (keys ++ vals ++ others) ->
    tabl ->
    list $keys
    -> sql_query [] [] [T = vals] []

val updateLookup :
    unchanged ::: {Type} -> uniques ::: {{Unit}} ->
    changed ::: {Type} -> [changed ~ unchanged] =>
    folder changed -> $(map sql_injectable changed) ->
    keys ::: {Type} -> [keys ~ changed ++ unchanged] =>
    folder keys -> $(map sql_injectable keys) ->
    sql_table (keys ++ changed ++ unchanged) uniques ->
    $keys ->
    $changed
    -> tunit

val deleteLookup :
    keys ::: {Type} -> others ::: {Type} -> uniques ::: {{Unit}} ->
    [keys ~ others] =>
    folder keys -> $(map sql_injectable keys) ->
    sql_table (keys ++ others) uniques ->
    $keys
    -> tunit

val compat :
    tabs ::: {{Type}} -> agg ::: {{Type}} -> exps ::: {Type} ->
    tab ::: Name -> keys ::: {Type} -> others ::: {Type} ->
    [keys ~ others] => [[tab] ~ tabs] =>
    folder keys -> $(map sql_injectable_prim keys) ->
    $(map option keys)
    -> sql_exp ([tab = (map option keys) ++ others] ++ tabs) agg exps bool

val selectCompat :
    keys ::: {Type} -> vals ::: {Type} -> others ::: {Type} ->
    [keys ~ vals] => [keys ~ others] => [vals ~ others] =>
    folder keys -> $(map sql_injectable_prim keys) ->
    tabl ::: Type -> fieldsOf tabl (map option keys ++ vals ++ others) ->
    tabl ->
    $(map option keys)
    -> sql_query [] [] [T = vals] []
