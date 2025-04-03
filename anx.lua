-- segment_request I must handle: cursor, clipboard

-- Events I must handle: registered, preroll, ident, segment_request (cursor, clipboard), message, resized, bridge-x11
function client_event_handler(source, status)
   if status.kind == "registered" then
   elseif status.kind == "preroll" then
	  target_displayhint(source, VRESW, VRESH, TD_HINT_IGNORE, {ppcm = VPPCM})
	  resize_image(source, VRESW, VRESH)
	  show_image(source)
   elseif status.kind == "ident" then
   elseif status.kind == "segment_request" then
	  if status.segkind == "cursor" then
		 local cursor =
			accept_target(
			   status.width,
			   status.height,
			   function(source,status)
				  if status.kind == "registered" then
				  elseif status.kind == "resized" then
					 show_image(source)
					 resize_image(source, status.width, status.height)
				  elseif status.kind == "terminated" then
					 delete_image(source)
				  elseif status.kind == "viewport" then
					 move_image(source, status.rel_x, status.rel_y)
				  elseif status.kind == "cursorhint" then
					 mouse_switch_cursor(status.cursor)
				  else
					 for k,v in pairs(status) do
						print(k,v)
					 end
				  end
			end)

		 if valid_vid(cursor) then
			show_image(cursor)
		 end

	  else
		 print(status.segkind)
	  end
   elseif status.kind == "message" then
	  print(status.message)
  elseif status.kind == "resized" then
	  resize_image(source, status.width, status.height)
	  show_image(source)
   elseif status.kind == "bchunkstate" then
   elseif status.kind == "cursorhint" then
	  mouse_switch_cursor(status.cursor)
   elseif status.kind == "bridge-x11" then
	  print("bridge-x11")
	  print(status)
   else
	  --print(status.kind)
   end

   XARCAN = source
end

function anx_input(input)
   if input.mouse then
	  mouse_iotbl_input(input)
	  
   elseif input.translated then
	  KEYBOARD:patch(input)
   end
   
   if XARCAN then
	  target_input(XARCAN, input)
   end
end

function anx(args)
   system_load("builtin/mouse.lua")()
   system_load("builtin/debug.lua")()
   system_load("builtin/string.lua")()
   system_load("builtin/table.lua")()
      
   KEYBOARD = system_load("builtin/keyboard.lua")()
   KEYBOARD:kbd_repeat()
   KEYBOARD:load_keymap()

   mouse_setup(load_image('cursor.png'), 65535, 1, true, true)

   for _, v in ipairs(list_targets("autorun")) do
	  if v == "xarcan" then
		 vid = launch_target(v, LAUNCH_INTERNAL, client_event_handler)
	  end
   end
end
