open Pp

let rec uniq_constr_list_env (l:(Constr.t * Environ.env) list) (res:(Constr.t * Environ.env) list) = 
  match l with
  | [] -> res
  | h::t -> 
      if List.filter (fun (x,envt) -> let c, envh = h in if (Constr.compare c x) = 0 then true else false) res = [] then
        uniq_constr_list_env t (h::res)
      else
        uniq_constr_list_env t res

let get_constr_const_body env sigma cx = 
  if Constr.isConst cx then 
    let c, u = Constr.destConst cx in
    let cb = Environ.lookup_constant c env in
      match Global.body_of_constant_body Library.indirect_accessor cb with
      | Some (e, _, _) -> Some e
      | None -> None
  else
    failwith "This term is not a constant"

let string_to_constr env sigma s = 
  let gr = Nametab.locate (Libnames.qualid_of_string s) in
  let cvar, info = 
    match gr with
    | Names.GlobRef.VarRef(v) -> Constr.mkVar v, "VarRef"
    | Names.GlobRef.ConstRef(c) -> Constr.UnsafeMonomorphic.mkConst c, "ConstRef"
    | Names.GlobRef.IndRef(i) -> Constr.UnsafeMonomorphic.mkInd i, "IndRef"
    | Names.GlobRef.ConstructRef(con) -> Constr.UnsafeMonomorphic.mkConstruct con, "ConstructRef"
  in
  cvar, info

let split_const const = 
  let l = String.split_on_char ',' const in 
  List.hd l


  let rec get_subterm_of_term c  =
  let open Constr in 
  let open Names in 
  match kind c with
  | Rel n -> []
  | Meta n -> []
  | Var id -> []
  | Sort s -> []
  | Cast (c,_, t) ->
      get_subterm_of_term c @ get_subterm_of_term t
  | Prod (_,t,c) -> get_subterm_of_term t @ get_subterm_of_term c
  | Lambda (na,t,c) -> get_subterm_of_term t @ get_subterm_of_term c
  | LetIn (na,b,t,c) -> get_subterm_of_term b @ get_subterm_of_term t @get_subterm_of_term c 
  | App (c,l) -> get_subterm_of_term c @ List.fold_left (fun acc x -> acc @ get_subterm_of_term x) [] (Array.to_list l)
  | Evar (e,l) ->
    List.fold_left (fun acc x -> match x with None -> acc | Some c -> acc @ get_subterm_of_term c) [] (SList.to_list l)

  | Const (c,u) -> 
    let s = Pp.string_of_ppcmds (try (Constant.debug_print c) with _ -> Pp.str "") in
    if s.[0] = '(' then  [split_const (String.sub s 1 (String.length s - 2))] else [split_const s] 
    
  | Ind ((sp,i),u) -> 
    let s = Pp.string_of_ppcmds (try (MutInd.print sp) with _ -> Pp.str "") in 
    if s.[0] = '(' then [String.sub s 1 (String.length s - 2)] else [s]
  | Construct (((sp,i),j),u) ->
    let s = Pp.string_of_ppcmds (try (MutInd.print sp)  with _ -> Pp.str "" ) in
    if s.[0] = '(' then [String.sub s 1 (String.length s - 2)] else [s]
  | Proj (p,_r,c) ->
    let s = Pp.string_of_ppcmds (try (Constant.debug_print (Projection.constant p))  with _ -> Pp.str "") in 
    if s.[0] = '(' then [String.sub s 1 (String.length s - 2)] @ get_subterm_of_term c else [s] @ get_subterm_of_term c
  | Case (_ci,_u,pms,(p,_),iv,c,bl) ->
    let pr_ctx (nas, c) =
        get_subterm_of_term c
    in
        get_subterm_of_term c @ List.fold_left (fun acc x -> acc @ get_subterm_of_term x) [] (Array.to_list pms) @ pr_ctx p @ debug_invert iv @ List.fold_left (fun acc x -> acc @ pr_ctx x) [] (Array.to_list bl)
  | Array(u,t,def,ty) -> 
      get_subterm_of_term def @ get_subterm_of_term ty
  | String _ -> []
  | _ -> []

and debug_invert = function
  | NoInvert -> []
  | CaseInvert {indices;} ->
    List.fold_left (fun acc x -> acc @ get_subterm_of_term x) [] (Array.to_list indices)
  

let uniq_constr_list constr_list = 
  let uniq_typ_list = List.sort_uniq Constr.compare constr_list in
  uniq_typ_list

let get_input_type env sigma lem = 
  let rel_context, expr =  Term.decompose_prod_decls lem in 
  let rel_context = Term.lambda_decls expr @ rel_context in
  let env = Environ.push_rel_context rel_context env in 
  let typ_list = List.map (fun x -> Context.Rel.Declaration.get_type x) rel_context in 
  let typ_list = List.mapi (fun i _ -> Typeops.type_of_relative env (i+1)) typ_list in
  (* let _ = Feedback.msg_debug (List.fold_left (fun acc x -> acc ++ (Printer.pr_constr_env env sigma x) ++ str ", ") (str "[") typ_list ++ str "]") in *)
  let typ_list = uniq_constr_list typ_list in 
  typ_list, env

  let rec get_subterm env sigma (c:Constr.t) =
    let open Constr in 
    (* Feedback.msg_debug (Printer.pr_constr_env env sigma c); *)
    (* let relcon = Environ.rel_context env in *)
    (* Feedback.msg_notice (Printer.pr_rel_context_of env sigma); *)
    (* one_subterm, env pair  *)
    match kind c with
    | Rel n -> []
    | Meta n -> []
    | Var id -> []
    | Sort s -> [] 
    | Cast (c,_, t) -> 
        let l1 = get_subterm env sigma c in
        let l2 = get_subterm env sigma t in 
        l1 @ l2
    | Prod (b ,t,c) -> 
      if isApp t then 
        let env1new =  Termops.push_rels_assum [(b , t)] env in
        let l1 = get_subterm env sigma t in
        let l2 = get_subterm env1new sigma c in
        [(t, env)] @ l1 @ l2
      else 
        let env1new =  Termops.push_rels_assum [(b , t)] env in
        let l1 = get_subterm env sigma t in
        let l2 = get_subterm env1new sigma c in
        l1 @ l2
    | Lambda (na,t,c) ->
      let env1new =  Termops.push_rels_assum [(na , t)] env in
      let l1 = get_subterm env sigma t in
      let l2 = get_subterm env1new sigma c in
      l1 @ l2
    | LetIn (na,b,t,c) -> 
      let l1 = get_subterm env sigma b in
      let l2 = get_subterm env sigma t in
      let l3 = get_subterm env sigma c in
      l1@l2@l3
    | App (c,l) -> 
        let lc = get_subterm env sigma c in
        
        let ll = List.fold_left (fun acc x -> let l1 = get_subterm env sigma x in acc @ l1) [] (Array.to_list l) in 
        lc @ ll
    | Const (c,u) -> 
      [(mkConstU (c,u), env)]
    | Ind ((sp,i),u) -> 
      [(mkIndU ((sp,i),u), env)]
    | Construct (((sp,i),j),u) -> 
      [(mkConstructU (((sp,i),j),u), env)]
    | Proj (p,_r,c) -> 
      let l1 = get_subterm env sigma c in
      [(mkProj (p,_r,c), env)] @ l1
    | _ -> []



  
  let one_inductive_body_to_str env sigma (ind_body:Declarations.one_inductive_body) = 
    let typename = ind_body.mind_typename in
    let consnames = ind_body.mind_consnames in
    let user_lc = ind_body.mind_user_lc in


    let constr_info_pp_l = List.map2 (fun constr_name constr_typ -> Names.Id.print constr_name ++ str " : " ++ Printer.pr_constr_env env sigma constr_typ ++ str ". ") (Array.to_list consnames) (Array.to_list user_lc)
    in
    [str "inductive name is " ++ Names.Id.print typename ++ str ", constructor are "] @ constr_info_pp_l @ [str "\n"]

let mutual_inductive_body_to_str env sigma (mind:Declarations.mutual_inductive_body) = 
  let mind_packets = mind.mind_packets in
  let s = List.map (fun x -> one_inductive_body_to_str env sigma x) (Array.to_list mind_packets) in
  let indinfo = List.concat s in
  string_of_ppcmds (List.fold_left (fun acc x -> acc ++ x) (str " ") indinfo)


let llm_typ_str env sigma typ = 
  (* Feedback.msg_notice (Pp.str "LLM pr_llm_typ"); *)
  match Constr.kind typ with
  | Constr.Ind (n ,v) ->
    let mind, oind = Global.lookup_inductive n in
    mutual_inductive_body_to_str env sigma mind
     (* Feedback.msg_notice (Printer.pr_inductive env n); *)
     (* Comptyp.extrind env sigma (EConstr.of_constr typ); *)
  (* | Constr.Const (n ,v) -> string_of_ppcmds (Printer.pr_constant env n) *)
  | _ -> ""

let typeof env sigma goal =
  let egoal = EConstr.of_constr goal in
  let res = 
  try
    let sigmanew, typ = Typing.type_of env sigma egoal in 
    Some (string_of_ppcmds (Printer.pr_econstr_env env sigmanew typ))
  with _ -> 
    None
  in
  res

let getinfo env sigma cgoal = 

  (* -------------------------------------------------------------------------------- *)

  let typ_list, new_env = get_input_type env sigma cgoal in
  let finetyp_list = List.concat (List.map (fun x -> get_subterm env sigma x) typ_list) in
  let finetyp_list = get_subterm env sigma cgoal @ finetyp_list in


  (* Feedback.msg_notice (str "-----------");
  let _ = List.iter (fun (x, envt) -> Feedback.msg_notice (Printer.pr_constr_env envt sigma x)) finetyp_list in
  Feedback.msg_notice (str "-----------"); *)

  let typ_list = List.filter (fun (x, envt) -> Constr.isInd x) finetyp_list in
  let typ_list = uniq_constr_list_env typ_list [] in

  (* -------------------------------------------------------------------------------- *)


  let func_list = List.sort_uniq String.compare (get_subterm_of_term cgoal) in
  (* List.iter (fun x -> print_endline x) func_list; *)

  let cconstrl = List.map (fun x -> string_to_constr env sigma x) func_list in

  let func_list = List.filter (fun (_, info) -> info = "ConstRef") cconstrl in
  let func_list = List.map (fun (x,_) -> x) func_list in
  let func_body_list = List.map (fun x -> match get_constr_const_body env sigma x with Some e -> Some e | None -> None) func_list in

  (* -------------------------------------------------------------------------------- *)


  (* Feedback.msg_notice (Pp.str "Goal Types are:"); *)
  (* let _ = List.iter (fun (x, envt) -> Feedback.msg_notice (Printer.pr_constr_env envt sigma x)) typ_list in *)
  let typinfo = List.fold_left (fun acc (x, envt) -> acc ^ (llm_typ_str envt sigma x)) "" typ_list in

  (* Feedback.msg_notice (Pp.str "Goal Functions are:"); *)
  let funinfo = List.fold_left2 (fun acc fnamem fbody -> 
      let fundefinfo = match fbody with 
      | Some b -> string_of_ppcmds (Printer.pr_constr_env env sigma fnamem) ^ " := " ^ string_of_ppcmds (Printer.pr_constr_env env sigma b) ^ ". "
      | None -> "" in

      let ress = match typeof env sigma fnamem with 
      | Some t -> fundefinfo ^ " And function " ^  string_of_ppcmds (Printer.pr_constr_env env sigma fnamem) ^ " type is " ^ t ^ "; "
      | None -> fundefinfo
      in
      acc ^ ress

      ) "" func_list func_body_list in 

      let infores = 
        match typinfo, funinfo with
        | "", "" -> ""
        | _, "" -> "Type information are: " ^ typinfo
        | "", _ -> "Function information are: " ^ funinfo
        | _, _ -> "Type information are: " ^ typinfo ^ ". " ^ "Function information are: " ^ funinfo
      in
      
    
    infores, List.map (fun x -> string_of_ppcmds (Printer.pr_constr_env env sigma x)) func_list @ List.map (fun (x, envx) -> string_of_ppcmds (Printer.pr_constr_env envx sigma x)) typ_list
  
let llminfo () = 
  Proofview.Goal.enter (fun gl ->
    let goal = Proofview.Goal.concl gl in
    let sigma = Proofview.Goal.sigma gl in
    let env = Proofview.Goal.env gl in
    (* Feedback.msg_notice (Pp.str "[LLM Info]"); *)
    let cgoal = EConstr.Unsafe.to_constr goal in

    let info, usedfunction = getinfo env sigma cgoal in 
    List.iter (fun x -> Feedback.msg_notice (str "[LLM Info] " ++ str x)) usedfunction;
  
    Feedback.msg_notice (Pp.str "[LLM Info] " ++ str info);

    Tacticals.tclIDTAC
  )
  