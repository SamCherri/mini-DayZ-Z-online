extends Node

## Contrato compartilhado do personagem RP temporário em memória.
##
## O cliente envia somente nome e sobrenome. O servidor identifica o peer pelo
## remote sender, valida os campos e decide se o personagem pode ser criado.

signal temporary_character_requested(
	peer_id: int,
	first_name: String,
	last_name: String,
)
signal temporary_character_accepted(peer_id: int, full_name: String)
signal temporary_character_rejected(reason: String)

const SERVER_PEER_ID := 1
const MIN_NAME_LENGTH := 3
const MAX_NAME_LENGTH := 16

var _name_pattern := RegEx.new()


func _ready() -> void:
	_name_pattern.compile("^[A-Za-z]+$")


@rpc("any_peer", "call_remote", "reliable")
func request_temporary_character(first_name: String, last_name: String) -> void:
	if not multiplayer.is_server():
		push_warning("CharacterProtocol: pedido de personagem rejeitado fora do servidor.")
		return

	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id <= SERVER_PEER_ID:
		push_warning("CharacterProtocol: pedido rejeitado por sender inválido.")
		return

	var normalized_first_name := first_name.strip_edges()
	var normalized_last_name := last_name.strip_edges()
	var rejection_reason := validate_name_part(normalized_first_name, "nome")
	if rejection_reason.is_empty():
		rejection_reason = validate_name_part(normalized_last_name, "sobrenome")
	if not rejection_reason.is_empty():
		reject_temporary_character.rpc_id(sender_id, rejection_reason)
		return

	temporary_character_requested.emit(
		sender_id,
		normalized_first_name,
		normalized_last_name,
	)


@rpc("authority", "call_remote", "reliable")
func accept_temporary_character(peer_id: int, full_name: String) -> void:
	if not _is_valid_server_response():
		return
	if peer_id != multiplayer.get_unique_id():
		push_warning("CharacterProtocol: aceite rejeitado para outro peer.")
		return

	print(
		"CharacterProtocol: personagem temporário aceito para peer %d: %s."
		% [peer_id, full_name]
	)
	temporary_character_accepted.emit(peer_id, full_name)


@rpc("authority", "call_remote", "reliable")
func reject_temporary_character(reason: String) -> void:
	if not _is_valid_server_response():
		return

	print("CharacterProtocol: personagem temporário rejeitado: %s" % reason)
	temporary_character_rejected.emit(reason)


func validate_name_part(value: String, field_name: String) -> String:
	if value.is_empty():
		return "O %s não pode ser vazio." % field_name
	if value.length() < MIN_NAME_LENGTH or value.length() > MAX_NAME_LENGTH:
		return (
			"O %s deve ter entre %d e %d caracteres."
			% [field_name, MIN_NAME_LENGTH, MAX_NAME_LENGTH]
		)
	if _name_pattern.search(value) == null:
		return "O %s deve usar somente letras ASCII, sem espaços ou símbolos." % field_name
	return ""


func _is_valid_server_response() -> bool:
	if multiplayer.is_server():
		push_warning("CharacterProtocol: servidor não deve receber a própria resposta.")
		return false
	if multiplayer.get_remote_sender_id() != SERVER_PEER_ID:
		push_warning("CharacterProtocol: resposta rejeitada porque não veio do servidor.")
		return false
	return true
