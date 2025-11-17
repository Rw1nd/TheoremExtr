

open Constr 
open Names
open Context

let ref2constr env sigma ref = 
  let mod_path = Pp.string_of_ppcmds (Names.GlobRef.print ref) in 
  let glob_ref = Globnames.canonical_gr ref in
  let typ = fst (Typeops.type_of_global_in_context env glob_ref) in

  let sigma, c_var = Evd.fresh_global env sigma glob_ref in 
  (* Feedback.msg_notice (Printer.pr_constr_env env sigma typ ++ Pp.str ": ");
  let terms = Mysearch.get_term typ in 
  print_string "[";
  let _ = List.iter (fun x -> print_string (x ^ ", ")) terms in
  print_string "]\n"; *)
  glob_ref, c_var, typ, mod_path

  let is_substring s sub =
    let re = Str.regexp_string sub
    in
      try ignore (Str.search_forward re s 0); true
      with Not_found -> false
  
  (* open Msg *)
  [@@@ocaml.warning "-26"]
  
  let uniq_constr_list constr_list = 
    let uniq_typ_list = List.sort_uniq Constr.compare constr_list in
    uniq_typ_list
  
  let j = Summary.ref ~name:"j" (`List [])
  
  let ebinder2prod sigma hpys goal = 
    let rec ebinder2prod_helper sigma hpys goal = 
      match hpys with
      | Context.Named.Declaration.LocalAssum (name, t)::xs -> 
        let  p = EConstr.mkNamedProd sigma name t goal in
          ebinder2prod_helper sigma xs p
      | Context.Named.Declaration.LocalDef (_)::xs -> ebinder2prod_helper sigma xs goal
      | [] -> goal
    in 
    EConstr.Unsafe.to_constr (ebinder2prod_helper sigma hpys (EConstr.of_constr goal))
  
  
  let get_one_ind env sigma ind = 
    let (sp, _) = ind in 
    let indname = Names.MutInd.to_string sp in
    let mind = fst (Inductive.lookup_mind_specif (Global.env ()) ind) in
    let ind_body = mind.mind_packets in
    let mind_nparams = mind.mind_nparams in 
  
    let get_one_ind_body (ind_body:Declarations.one_inductive_body) = 
      (* let typename = ind_body.mind_typename in *)
      (* let arity_ctxt = ind_body.mind_arity_ctxt in *)
      let consnames = ind_body.mind_consnames in
      let cons_num = Array.length consnames in 
      let user_lc = ind_body.mind_user_lc in
      (* let mind_nrealargs = ind_body.mind_nrealargs in *)
  
      let (obj:Yojson.Basic.t) = `Assoc [("indinfo", 
      `Assoc [("cons_num", `Int cons_num); 
      ("indname", `String indname);
      ("mind_nparams", `Int mind_nparams); 
      ("consnames", `List (List.map (fun x -> `String (Pp.string_of_ppcmds (Names.Id.print x))) (Array.to_list consnames)));
      ("user_lc", `List (List.map (fun x -> `String (Pp.string_of_ppcmds (Printer.pr_constr_env env sigma x))) (Array.to_list user_lc)));
      ])] in
      obj
    in
    let obj_list = List.map (fun x -> get_one_ind_body x) (Array.to_list ind_body) in 
    (* let _ = List.iter (fun x -> print_string (Yojson.Basic.to_string x)) obj_list in *)
    obj_list
  
  
let get_ind_info env sigma typ =
  let rec find_ind env sigma typ = 
    match Constr.kind typ with
    | Constr.Ind (ind, _) -> [ind]
    | Constr.App (c, l) -> 
      find_ind env sigma c @ List.fold_left (fun acc x -> acc @ find_ind env sigma x) [] (Array.to_list l)
    | _ -> []
  in
  let ind_list = find_ind env sigma typ in
  let obj_list = List.fold_left (fun acc x -> acc @ get_one_ind env sigma x) [] ind_list in

  let one_obj = if ind_list = [] then `Null else `List obj_list in
  one_obj

let split_const const = 
  let l = String.split_on_char ',' const in 
  List.hd l
  let rec get_term c  =
  match kind c with
  | Rel n -> []
  | Meta n -> []
  | Var id -> []
  | Sort s -> []
  | Cast (c,_, t) ->
      get_term c @ get_term t
  | Prod ({binder_name=Name id;_},t,c) -> get_term t @ get_term c
  | Prod ({binder_name=Anonymous;_},t,c) -> get_term t @ get_term c
  | Lambda (na,t,c) -> get_term t @ get_term c
  | LetIn (na,b,t,c) -> get_term b @ get_term t @get_term c 
  | App (c,l) -> get_term c @ List.fold_left (fun acc x -> acc @ get_term x) [] (Array.to_list l)
  | Evar (e,l) ->
    List.fold_left (fun acc x -> match x with None -> acc | Some c -> acc @ get_term c) [] (SList.to_list l)

  | Const (c,u) -> 
    let s = Pp.string_of_ppcmds (try (Constant.debug_print c) with _ -> Pp.str "") in
    if s.[0] = '(' then [split_const (String.sub s 1 (String.length s - 2))] else [split_const s]

  | Ind ((sp,i),u) -> 
    let s = Pp.string_of_ppcmds (try (MutInd.print sp) with _ -> Pp.str "") in 
    if s.[0] = '(' then [String.sub s 1 (String.length s - 2)] else [s]
  | Construct (((sp,i),j),u) ->
    let s = Pp.string_of_ppcmds (try (MutInd.print sp)  with _ -> Pp.str "" ) in
    if s.[0] = '(' then [String.sub s 1 (String.length s - 2)] else [s]
  | Proj (p,_r,c) ->
    let s = Pp.string_of_ppcmds (try (Constant.debug_print (Projection.constant p))  with _ -> Pp.str "") in 
    if s.[0] = '(' then [String.sub s 1 (String.length s - 2)] @ get_term c else [s] @ get_term c
  | Case (_ci,_u,pms,(p,_),iv,c,bl) ->
    let pr_ctx (nas, c) =
        get_term c
    in
        get_term c @ List.fold_left (fun acc x -> acc @ get_term x) [] (Array.to_list pms) @ pr_ctx p @ debug_invert iv @ List.fold_left (fun acc x -> acc @ pr_ctx x) [] (Array.to_list bl)
  | Array(u,t,def,ty) -> 
      get_term def @ get_term ty
  | String _ -> []
  | _ -> []

and debug_invert = function
  | NoInvert -> []
  | CaseInvert {indices;} ->
    List.fold_left (fun acc x -> acc @ get_term x) [] (Array.to_list indices)
    
  
  let get_type env sigma goal = 
    let rel_context, expr =  Term.decompose_prod_decls goal in 
    let rel_context = Term.lambda_decls expr @ rel_context in
  
    let env = Environ.push_rel_context rel_context env in 
  
    let typ_list = List.map (fun x -> Rel.Declaration.get_type x) rel_context in 
  
    let typ_list = List.mapi (fun i _ -> Typeops.type_of_relative env (i+1)) typ_list in
    
    let typ_list = uniq_constr_list typ_list in 
  
    let ind_list = List.map (fun x -> get_ind_info env sigma x) typ_list in
  
    let typ_list = `List (List.map (fun x -> `String (Pp.string_of_ppcmds (Printer.pr_constr_env env sigma x))) typ_list) in 
    (* let env = Environ.pop_rel_context 1 env in *)
    typ_list, ind_list
  
  
  (* let debugcount = ref 0 *)
  
  let show env sigma hpys name the_type = 

  
    if is_substring name "__proof" then
      ()
    else
  
    let let_prod_lemma = ebinder2prod sigma hpys the_type in
    let typ_list, ind_info = get_type env sigma let_prod_lemma in 
  
    let clist = List.sort_uniq String.compare (get_term the_type) in
    let llminfo, usedfunction = Llminfo.getinfo env sigma the_type in
    let usedfunction = List.map (fun x -> `String x) usedfunction in
  

  
    let j_list = `List (List.map (fun x -> `String x) clist) in
  
    let (obj:Yojson.Basic.t) = `Assoc [
      ("Input_type", typ_list);
      ("feature", j_list); 
    ("Type",`String (Pp.string_of_ppcmds (Printer.pr_constr_env env sigma the_type)));
     ("lemmaname", `String name); 
     (* ("subterm", str_term_list);  *)
     ("ind_info", `List ind_info);
     ("llminfo", `String llminfo);
     ("usedfunction", `List usedfunction)
     ] 
    in
  
    j := `List (obj :: (match !j with `List l -> l | _ -> []));
    ()
  



  let alldef env sigma = 
    let save_in_list refl glob_ref env sigma c = refl := glob_ref :: !refl in
    let ans = ref [] in
    let filter glob_ref kind env sigma typ =
      true
    in
    let iter glob_ref kind env sigma typ =
      if filter glob_ref kind env sigma typ then save_in_list ans glob_ref env sigma typ
    in
    let env = Global.env () in
    let sigma = Evd.from_env env in
    let () = Search.generic_search env sigma iter in
    List.filter
       (fun glob_ref ->
        try
          ignore (Typeops.type_of_global_in_context env glob_ref);
          true
        with _ ->
          false
       )
      (List.rev !ans)



  let savejson env sigma = 
    let open Yojson.Basic in 
    let jsonpath = "/home/opam/data/env_json/" in
    let cur_mod = Global.current_modpath () in
    let filename = ModPath.to_string cur_mod ^ ".json" in
    let oc = open_out (jsonpath ^ filename) in
    output_string oc (to_string !j);
    close_out oc;
    Feedback.msg_notice (Pp.str ("Saved to " ^ jsonpath ^ filename));
    ()
