
val alldef : Environ.env -> Evd.evar_map -> Names.GlobRef.t list
val show : Environ.env -> Evd.evar_map -> ('a, Evd.econstr, Evd.erelevance) Context.Named.Declaration.pt list -> string -> Constr.t -> unit
val savejson :  Environ.env -> Evd.evar_map -> unit
val ref2constr : Environ.env -> Evd.evar_map -> Names.GlobRef.t ->  Names.GlobRef.t * Evd.econstr * Constr.t * string
