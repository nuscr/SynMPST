type role = string

type value_type = string

type message_label =
  { name : string
  ; payloads : value_type list
  }

type rec_var = string

type 'a protocol =
  { protocol_name : string
  ; roles : string list
  ; interactions : 'a
  }

type transition_label = {sender: role ; receiver: role ; label: message_label}

let string_of_transition_label lbl =
  lbl.sender ^ "->" ^ lbl.receiver ^ "<" ^ lbl.label.name ^ ">"

module Local = struct

  type direction = Sending | Receiving

  type local_transition_label = {sender: role ; receiver: role ; direction : direction ; label: message_label}

  let string_of_local_transition_label lbl =
    let dir = match lbl.direction with Sending -> "!" | Receiving -> "?" in
    lbl.sender ^ dir ^ lbl.receiver ^ "<" ^ lbl.label.name ^ ">"
end


type global  (* consider renaming just global *)
  = MessageTransfer of transition_label
  | Choice of global list
  | Fin of global
  | Inf of global
  | Par of global list
  | Seq of global list

type compilation_unit = global protocol list


let rec validate_roles roles = function
  | MessageTransfer {sender ; receiver ; label = _} ->
    if List.mem sender roles && List.mem receiver roles then true
    else Error.UserError "Unknown role used in protocol." |> raise
  | Choice branches
  | Par branches
  | Seq branches ->
    List.for_all (validate_roles roles) branches
  | Fin g
  | Inf g ->
    validate_roles roles g


let validate_global_protocol protocol =
  validate_roles protocol.roles protocol.interactions

let validate_compilation_unit cu =
  List.for_all validate_global_protocol cu

(* local "types" *)

type local = global * role
