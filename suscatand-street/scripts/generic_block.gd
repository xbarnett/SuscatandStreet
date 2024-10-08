class_name GenericBlock extends CenterContainer

@export var value_name: String
@export var block_type: String
@export var i_am_a_block: bool = true 
@export var connectors: Array[ConnectorNode]
@export var dragging_enabled: bool = true

var name_space: Namespace

var dragging: bool = false
var dragStartPos: Vector2
var originalPos: Vector2


func _ready():
	#$Control/Label.text = value_name
	focus_mode = FocusMode.FOCUS_ALL
	connect("gui_input", Callable(self, "_on_gui_input"))
	for connector in $Connectors.get_children():
		connectors.push_back(connector)

func _gui_input(event):
	if not dragging_enabled:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			accept_event()
			if event.pressed:
				dragging = true
				self.modulate = Color(0.95,0.95,0.95)
				originalPos = global_position
				dragStartPos = get_global_mouse_position() - global_position
			else:
				dragging = false
				self.modulate = Color(1,1,1)
				var landing_spot = find_landing_spot()
				if landing_spot:
					#position = landing_spot.get_local_mouse_position() - size / 2
					global_position = get_global_mouse_position() - dragStartPos
				else:
					global_position = originalPos
	elif event is InputEventMouseMotion and dragging:
		accept_event()
		global_position = get_global_mouse_position() - dragStartPos

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() - dragStartPos

func find_landing_spot() -> Node:
	var mouse_pos = get_global_mouse_position()
	var panel_container = get_tree().get_root().get_node("root/CanvasLayer/HBoxContainer/HSplitContainer/PanelContainer")
	var graveyard = get_tree().get_root().get_node("root/CanvasLayer/HBoxContainer/InventoryContainer/Control2/Inventory")
	var connector_coordinator = get_tree().get_root().get_node("root/CanvasLayer/HBoxContainer/HSplitContainer/PanelContainer/BackendCommunicator/ConnectorCoordinator")
	#var panel_container = get_node_or_null("/root/CanvasLayer/HBoxContainer/HSplitContainer/PanelContainer")
	#var graveyard = get_node_or_null("/root/CanvasLayer/HBoxContainer/InventoryContainer/Graveyard")
	
	if graveyard and graveyard.get_global_rect().has_point(mouse_pos):
		
		# clean connectors
		for connector in connectors:
			for c in connector_coordinator.connectors:
				c.connectedNodes.erase(connector)
				
		self.get_parent().remove_child(self)
		connector_coordinator.init_connectors()
		
		queue_free()
		return null
	if panel_container and panel_container.get_global_rect().has_point(mouse_pos):
		return panel_container
	return null
