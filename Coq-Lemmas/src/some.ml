open Pp
let show env sigma e1 = 
  let _p = Printer.pr_econstr_env env sigma e1 in 
  Feedback.msg_notice (Pp.str "[CMD] " ++ _p);
  ()


let getcontext () =
  Proofview.Goal.enter (fun gl ->
    let goal = Proofview.Goal.concl gl in
    let sigma = Proofview.Goal.sigma gl in
    let env = Proofview.Goal.env gl in
    let hyps = Proofview.Goal.hyps gl in
    let pp_goal = Printer.pr_econstr_env env sigma goal in 
    let pp_hyps = List.map (fun x -> Pp.(++) (Printer.pr_enamed_decl env sigma x) (Pp.str ", ")) hyps in
    Feedback.msg_notice (Pp.str "[Goal] " ++ pp_goal);
    Feedback.msg_notice (Pp.str "[Hyps] " ++ (List.fold_left (fun x acc -> x ++ acc) (Pp.strbrk " ") pp_hyps));
    Tacticals.tclIDTAC
  )

