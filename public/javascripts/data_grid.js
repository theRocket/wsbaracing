lastClickAt = 0;
selectedId = null;
idRegex = /\d+/;

function clicked(e) {
  if (!e) var e = window.event

  if (e.target) targ = e.target;
  else if (e.srcElement) targ = e.srcElement;
  // defeat Safari bug
  if (targ.nodeType == 3) targ = targ.parentNode;

  if (targ.localName != "DIV" && targ.localName != "div") {
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
  select(findRow(e.target));
  return false;
}

function findRow(element) {
  if (element.hasClassName("row")) {
    return element;
  }
  else {
    return findRow(element.parentNode);
  }
}

function select(row) {
  if (!row.hasClassName("selected")) {
    $("rows").childElements().each(function(row) { row.removeClassName("selected"); });
    selectedId = idRegex.exec(row.id);
    row.addClassName("selected");
    enable_button("delete_button");
    enable_button("results_button");
    enable_button("edit_button");
  }
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

function captureClick(row) {
  row.onclick = clicked;
  if (row.captureEvents) row.captureEvents(Event.CLICK);
}

function resize() {
  if (window.innerHeight < 100) {
    $("teams").setStyle({ height: 'auto' });
  }
  else {
    var newHeight = window.innerHeight - 260;
    if (newHeight < 50) newHeight = 50;
    $("rows").setStyle({ height: newHeight + 'px' });
  }
}

function delete_team() {
  if (selectedId != null) {
    var name = $('team_' + selectedId).textContent;
    if (confirm('Really delete ' + name + "?")) { 
      new Ajax.Request('/admin/teams/' + selectedId, {asynchronous:true, evalScripts:true, method:'delete'}); 
    } 
  }
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

function cancelEdit(id) {
  new Ajax.Updater('team_' + id, '/admin/teams/cancel/' + id, {asynchronous:true, evalScripts:true});
  return false;
}