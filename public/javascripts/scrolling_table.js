// TODO Droppables still accept drop, even when scrolled out of view? (all)
// TODO Check for values that could be cached
// TODO Handle clicks better. Replace global variable with better event handling. Current code breaks selection.
// TODO Disabled Draggable and update UI as well as Droppable?
// TODO Ensure Drag and drops are recreated afterwards
// TODO Ensure everything (dragging, editing) is really disabled after drop

function newScrollingTable(pluralRecordType, recordType, recordIds) {
  var scrollingTable = $(pluralRecordType);
  scrollingTable.pluralRecordType  = pluralRecordType;
  scrollingTable.recordType = recordType;
  scrollingTable.recordIds = recordIds;
  scrollingTable.lastClickAt = 0;
  scrollingTable.selectedId = null;
  scrollingTable.idRegex = /\d+/;
  
  scrollingTable.addDraggableFor = function(recordId) {
    var draggable = new Draggable(this.recordType + '_' + recordId, 
                              { delay:100,
                                scroll: $('records'),
                                superghosting: true,
                                revert: 'failure',
                                onStart: function() { Droppables.remove(this.recordType + '_' + this.recordId + '_row') },
                                reverteffect: function(element, top_offset, left_offset) {
                                  scrollingTable.addDroppableRowFor(recordId);
                                  var dur = Math.sqrt(Math.abs(top_offset^2)+Math.abs(left_offset^2))*0.02;
                                  new Effect.Move(element, { x: -left_offset, y: -top_offset, duration: dur,
                                    queue: {scope:'_draggable', position:'end'}
                                  });
                                }
                              }
                            );
    draggable.scrollingTable = scrollingTable;
  }
  
  scrollingTable.addDroppableRowFor = function(recordId) {
    var droppable = Droppables.add(this.recordType + '_' + recordId + '_row', 
                   { hoverclass:'hovering', 
                     onDrop:function(element) {
                       if (this.scrollingTable.isDroppableVisible(this.scrollingTable.recordType + '_' + recordId + '_row')) {
                         this.scrollingTable.disableDragAndDrop(recordId);
                         this.scrollingTable.showDragAndDropDisabled(recordId);
                         var droppedId = this.scrollingTable.idRegex.exec(element.id);
                         this.scrollingTable.showDragAndDropDisabled(droppedId);
                         this.scrollingTable.disableDragAndDrop(droppedId);
                         new Ajax.Request('/admin/' + this.scrollingTable.pluralRecordType + '/merge?target_id=' + recordId, 
                                          { asynchronous:true, 
                                            evalScripts:true, 
                                            parameters:'id=' + encodeURIComponent(droppedId)
                                           }
                                          );
                        }
                        else {
                          return false;
                        }
                 }});
    droppable.scrollingTable = this;
  }

  scrollingTable.isDroppableVisible = function(droppableId) {
    var droppable = $(droppableId);
    var droppableY = droppable.cumulativeOffset()[1] - droppable.cumulativeScrollOffset()[1];
    var recordsTop = $('records').cumulativeOffset()[1];
    var recordsBottom = recordsTop + $('records').getHeight();
    return (droppableY >= recordsTop) && (droppableY <= recordsBottom);
  }

  scrollingTable.disableDragAndDrop = function(recordId) {
    Droppables.remove(this.recordType + '_' + recordId + '_row');
    var originalDraggable = Draggables.drags.find(function(d) { 
      return d.element.id == (this.recordType + '_' + recordId) 
    }, this );
    originalDraggable.destroy();
  }

  // After drop, we want to make a big deal that something is happening.
  // When editing, we want to be more subtle.
  scrollingTable.showDragAndDropDisabled = function(recordId) {
    new Effect.Opacity(this.recordType + '_' + recordId + '_row', { from: 1.0, to: 0.5, duration: 0.5 });
    $(this.recordType + '_' + recordId + '_row').addClassName("disabled");
  }

  scrollingTable.clicked = function(e) {
    if (!e) var e = window.event

    if (e.target) targ = e.target;
    else if (e.srcElement) targ = e.srcElement;
    // defeat Safari bug
    if (targ.nodeType == 3) targ = targ.parentNode;

    // TODO Refactor
    if (targ.localName == "a" || targ.localName == "A" || targ.localName == "input" || targ.localName == "INPUT" || targ.localName == "img" || targ.localName == "IMG") {
      return true;
    }

    // TODO Check last click position, too
    if ((new Date().getTime() - lastClickAt) <= 250) {
      e.cancelBubble = true;
      if (e.stopPropagation) e.stopPropagation();
      select(targ.up('tr'));
      redirectToEdit($(selectedId).pluralRecordType);
      return false;
    }

    lastClickAt = new Date().getTime();
    e.cancelBubble = true;
    if (e.stopPropagation) e.stopPropagation();
    select(targ.up('tr'));
    return false;
  }

  scrollingTable.select = function(row) {
    if (!row.hasClassName("selected")) {
      clearSelection();
      selectedId = idRegex.exec(row.id);
      row.addClassName("selected");
      enableButton("delete_button");
      enableButton("results_button");
      enableButton("edit_button");
    }
  }

  scrollingTable.clearSelection = function() {
    selectedId = null;
    $$('div.records tbody > tr').each(function(row) { row.removeClassName("selected"); });
  }

  scrollingTable.enableButton = function(id) {
    if ($(id).hasClassName("disabled")) {
      $(id).removeClassName("disabled");
    }
  }

  scrollingTable.disableButton = function(id) {
    if (!$(id).hasClassName("disabled")) {
      $(id).addClassName("disabled");
    }
  }

  scrollingTable.captureClick = function(recordId) {
    row = $(this.recordType + '_' + recordId + '_row');
    row.onclick = this.clicked;
    if (row.captureEvents) row.captureEvents(Event.CLICK);
  }  

  scrollingTable.deleteRecord = function() {
    if (selectedId != null) {
      var name = $(recordType + '_' + selectedId).textContent.strip();
      if (confirm('Really delete ' + name + '?')) { 
        new Ajax.Request('/admin/' + this.pluralRecordType + 's/' + selectedId, {asynchronous:true, evalScripts:true, method:'delete'}); 
      } 
    }
    return false;
  }

  scrollingTable.redirectToNew = function() {
    window.location = "/admin/' + this.pluralRecordType + '/new";
    return false;
  }

  scrollingTable.redirectToResults = function() {
    if (selectedId != null) window.location = "/results/" + this.recordType + "/" + selectedId;
    return false;
  }

  scrollingTable.redirectToEdit = function() {
    if (selectedId != null) {
      window.location = "/admin/" + $(selectedId).pluralRecordType + "/" + selectedId + "/edit";    
    }
    return false;  
  }

  scrollingTable.cancelEditName = function(recordId) {
    new Ajax.Updater(recordType + recordType + '_' + id, '/admin/' + recordType + 's/cancel_edit_name/' + id, {asynchronous:true, evalScripts:true});
    return false;
  }

  scrollingTable.restripe = function() {
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
  
  for (var i=0; i < recordIds.length; i++) {
    scrollingTable.captureClick(recordIds[i]);  
    scrollingTable.addDroppableRowFor(recordIds[i]);
    scrollingTable.addDraggableFor(recordIds[i]);
  };
}

/* Cache values to make slow operation as fast as possible */
function resize() {
  var document_viewport_height = document.viewport.getHeight();
  var records = $('records');
  if (document_viewport_height < 100) {
    records.setStyle({ height: 'auto' });
  }
  else {
    var newHeight = records.getHeight() + (document_viewport_height - $('frame').getHeight()) - 20;
    if (newHeight < 50) newHeight = 50;
    records.setStyle({ height: newHeight + 'px' });
  }
}
