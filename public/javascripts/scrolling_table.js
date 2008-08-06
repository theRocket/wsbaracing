// Issues:
// Draggable jumps oddly when scrolling (FF, S, IE?)
// Hover coordinates incorrect after scroll? (all)
// Droppables still accept drop, even when scrolled out of view? (all)

lastClickAt = 0;
selectedId = null;
idRegex = /\d+/;
// TODO replace global variable with better event handling
dragging = false;

// TODO Disabled Draggable and update UI as well as Droppable?
// TODO Ensure Drag and drops are recreated afterwards
// TODO Ensure everything (dragging, editing) is really disabled after drop
function add_droppable_row_for(record_id) {
  Droppables.add('team_' + record_id + '_name', 
                 { hoverclass:'hovering', 
                   onDrop:function(element) {
                     // console.log(element.cumulativeOffset());
                     // console.log(element.getDimensions());
                     // console.log(element.getOffsetParent());
                     // console.log(element.viewportOffset());
                     // Droppables.remove('team_' + record_id + '_row');
                     // $('team_' + record_id).addClassName("disabled");
                     // new Effect.Opacity('team_' + record_id + '_row', { from: 1.0, to: 0.5, duration: 0.5 });
                     // new Ajax.Request('/admin/teams/merge?target_id=' + record_id, 
                     //                  { asynchronous:true, 
                     //                    evalScripts:true, 
                     //                    parameters:'id=' + encodeURIComponent(idRegex.exec(element.id))
                     //                   }
                     //                  );
                     }})  
}

function add_draggable_for(record_id) {
  new Draggable('team_' + record_id + '_name', { delay:100,
                                       scroll: $('records'),
                                       // ghosting: !Prototype.Browser.IE,
                                       superghosting: true,
                                       revert: true,
                                       onEnd:function() { add_droppable_row_for(record_id); },
                                       onStart:function() { Droppables.remove('team_' + record_id + '_name'); dragging = true;}
                                     }
                );
}

function clicked(e) {
  if (!e) var e = window.event
  
  if (e.target) targ = e.target;
  else if (e.srcElement) targ = e.srcElement;
  // defeat Safari bug
  if (targ.nodeType == 3) targ = targ.parentNode;

  if (targ.localName == "a" || targ.localName == "A") {
    return true;
  }

  // TODO Check last click position, too
  if ((new Date().getTime() - lastClickAt) <= 250) {
    e.cancelBubble = true;
    if (e.stopPropagation) e.stopPropagation();

    redirectToEdit(idRegex.exec(targ.parentNode.id));
    return false;
  }
  
  lastClickAt = new Date().getTime();
  e.cancelBubble = true;
  if (e.stopPropagation) e.stopPropagation();
  if (dragging) {
    // dragging = false;
  }
  else {
    select(targ.up('tr'));
  }
  return false;
}


function select(row) {
  if (!row.hasClassName("selected")) {
    clearSelection();
    selectedId = idRegex.exec(row.id);
    row.addClassName("selected");
    enable_button("delete_button");
    enable_button("results_button");
    enable_button("edit_button");
  }
}

function clearSelection() {
  selectedId = null;
  $$('div.records tbody > tr').each(function(row) { row.removeClassName("selected"); });
}

function enable_button(id) {
  if ($(id).hasClassName("disabled")) {
    $(id).removeClassName("disabled");
  }
}

function disable_button(id) {
  if (!$(id).hasClassName("disabled")) {
    $(id).addClassName("disabled");
  }
}

function captureClick(record_id) {
  row = $('team_' + record_id + '_row');
  row.onclick = clicked;
  if (row.captureEvents) row.captureEvents(Event.CLICK);
}

// TODO Fix flash messages makes table too tall
// TODO Throws JavaScript error in IE
function resize() {
  // if (window.innerHeight < 100) {
  //   $("teams").setStyle({ height: 'auto' });
  // }
  // else {
  //   var newHeight = window.innerHeight - 260;
  //   if (newHeight < 50) newHeight = 50;
  //   $("rows").setStyle({ height: newHeight + 'px' });
  // }
}

function deleteTeam() {
  if (selectedId != null) {
    var name = $('team_' + selectedId).textContent.strip();
    if (confirm('Really delete ' + name + "?")) { 
      new Ajax.Request('/admin/teams/' + selectedId, {asynchronous:true, evalScripts:true, method:'delete'}); 
    } 
  }
  return false;
}

function redirectToNew() {
  window.location = "/admin/teams/new";
  return false;
}

function redirectToResults() {
  if (selectedId != null) window.location = "/results/team/" + selectedId;
  return false;
}

function redirectToEdit(id) {
  if (id == null) id = selectedId;
  if (id != null) window.location = "/admin/teams/" + id + "/edit";
  return false;  
}

function cancelEditName(id) {
  new Ajax.Updater('team_' + id, '/admin/teams/cancel_edit_name/' + id, {asynchronous:true, evalScripts:true});
  return false;
}

function restripeTable() {
  index = 0;
  $('records').down('tbody').childElements().each(function(row) {
    if (row.hasClassName('even') || row.hasClassName('odd')) {
      row.removeClassName('odd');
      row.removeClassName('even');
      if (index % 2 == 0) {
        row.addClassName('even');
      }
      else {
        row.addClassName('odd');
      }
      index = index + 1;
    }
  });
}
