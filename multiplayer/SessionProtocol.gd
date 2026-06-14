extends Node

## Contrato compartilhado da sessão temporária em memória.
##
## O cliente envia somente o nome desejado. O servidor identifica o peer pelo
## remote sender, valida o nome e decide se a sessão pode ser criada.

signal session_requested(peer_id: int, display_name: String)
signal session_accepted(peer_id: int, display_name: String)
signal session_rejected(reason: String)

const SERVER_PEER_ID := 1
const MIN_DISPLAY_NAME_LENGTH := 3
const MAX_DISPLAY_NAME_LENGTH := 20
const INVALID_NAME_REASON := (
	"O nome deve ter entre %d e %d caracteres e usar apenas letras, números ou _."
	% [MIN_DISPLAY_NAME_LENGTH, MAX_DISPLAY_NAME_LENGTH]
)

var _display_name_pattern := RegEx.new()


func _ready() -> void:
	_display_name_pattern.compile("^[A-Za-z0-9_]+$")


@rpc("any_peer", "call_remote", "reliable")
func request_session(display_name: String) -> void:
	if not multiplayer.is_server():
		push_warning("SessionProtocol: pedido de sessão rejeitado fora do servidor.")
		return

	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id <= SERVER_PEER_ID:
		push_warning("SessionProtocol: pedido rejeitado por sender inválido.")
		return

	var normalized_name := display_name.strip_edges()
	var rejection_reason := validate_display_name(normalized_name)
	if not rejection_reason.is_empty():
		reject_session.rpc_id(sender_id, rejection_reason)
		return

	session_requested.emit(sender_id, normalized_name)


@rpc("authority", "call_remote", "reliable")
func accept_session(peer_id: int, display_name: String) -> void:
	if not _is_valid_server_response():
		return
	if peer_id != multiplayer.get_unique_id():
		push_warning("SessionProtocol: aceite rejeitado para outro peer.")
		return

	print(
		"SessionProtocol: sessão aceita para peer %d com nome %s."
		% [peer_id, display_name]
	)
	session_accepted.emit(peer_id, display_name)


@rpc("authority", "call_remote", "reliable")
func reject_session(reason: String) -> void:
	if not _is_valid_server_response():
		return

	print("SessionProtocol: sessão rejeitada: %s" % reason)
	session_rejected.emit(reason)


func validate_display_name(display_name: String) -> String:
	if display_name.is_empty():
		return INVALID_NAME_REASON
	if (
		display_name.length() < MIN_DISPLAY_NAME_LENGTH
		or display_name.length() > MAX_DISPLAY_NAME_LENGTH
	):
		return INVALID_NAME_REASON
	if _display_name_pattern.search(display_name) == null:
		return INVALID_NAME_REASON
	return ""


func _is_valid_server_response() -> bool:
	if multiplayer.is_server():
		push_warning("SessionProtocol: servidor não deve receber a própria resposta.")
		return false
	if multiplayer.get_remote_sender_id() != SERVER_PEER_ID:
		push_warning("SessionProtocol: resposta rejeitada porque não veio do servidor.")
		return false
	return true
