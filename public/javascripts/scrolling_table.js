// Issues:
// Droppables still accept drop, even when scrolled out of view? (all)

lastClickAt = 0;
selectedId = null;
idRegex = /\d+/;
// TODO replace global variable with better event handling. Is this hiding a scriptalicous variable?
dragging = false;

// TODO Disabled Draggable and update UI as well as Droppable?
// TODO Ensure Drag and drops are recreated afterwards
// TODO Ensure everything (dragging, editing) is really disabled after drop
// Move DOM-ready to one method that encapsulates all of this behavior
// TODO Disable DD when editing
// TODO Re-enable DD after editing
// TODO Scroll to bottom of merge? message

ScrollingTableDDProxy = function(id, recordName, config) {
  this.recordName = recordName;
  ScrollingTableDDProxy.superclass.constructor.call(this, id, "default", config);
};

YAHOO.extend(ScrollingTableDDProxy, YAHOO.util.DDProxy, {
  labelText: "",
  
  createFrame: function() {
    var self=this, body=document.body;

    if (!body || !body.firstChild) {
        setTimeout( function() { self.createFrame(); }, 50 );
        return;
    }

    var div=this.getDragEl(), Dom=YAHOO.util.Dom;

    if (!div) {
        div    = document.createElement("div");
        div.id = this.dragElId;

        var s  = div.style;
        s.position   = "absolute";
        s.visibility = "hidden";
        s.cursor     = "default";
        s.zIndex     = 999;
        s.height     = "auto";
        s.width      = "auto";
        s.minWidth  = "200px";
        s.minHeight   = "20px";
        s.backgroundImage = "url(/images/icons/people.gif)";
        s.backgroundRepeat = "no-repeat";
        s.backgroundPosition = "4px 2px";
        s.paddingLeft = "32px";
        s.fontFamily = this.getEl().style.fontFamily;
        s.fontSize = this.getEl().style.fontSize;
        // Dom.setStyle should work cross-browser.
        Dom.setStyle(div, 'opacity', '0.5');

        var _data = document.createElement('div');
        Dom.setStyle(_data, 'height', '100%');
        Dom.setStyle(_data, 'width', '100%');
        /**
        * If the proxy element has no background-color, then it is considered to the "transparent" by Internet Explorer.
        * Since it is "transparent" then the events pass through it to the iframe below.
        * So creating a "fake" div inside the proxy element and giving it a background-color, then setting it to an
        * opacity of 0, it appears to not be there, however IE still thinks that it is so the events never pass through.
        */
        Dom.setStyle(_data, 'background-color', '#ccc');
        Dom.setStyle(_data, 'opacity', '0');
        div.appendChild(_data);

        /**
        * It seems that IE will fire the mouseup event if you pass a proxy element over a select box
        * Placing the IFRAME element inside seems to stop this issue
        */
        if (YAHOO.env.ua.ie) {
            //Only needed for Internet Explorer
            var ifr = document.createElement('iframe');
            ifr.setAttribute('src', 'about:blank');
            ifr.setAttribute('scrolling', 'no');
            ifr.setAttribute('frameborder', '0');
            div.insertBefore(ifr, div.firstChild);
            Dom.setStyle(ifr, 'height', '100%');
            Dom.setStyle(ifr, 'width', '100%');
            Dom.setStyle(ifr, 'position', 'absolute');
            Dom.setStyle(ifr, 'top', '0');
            Dom.setStyle(ifr, 'left', '0');
            Dom.setStyle(ifr, 'opacity', '0');
            Dom.setStyle(ifr, 'zIndex', '-1');
            Dom.setStyle(ifr.nextSibling, 'zIndex', '2');
        }

        // IE is happiest if this occurs later rather than earlier
        div.innerHTML = this.recordName;

        // appendChild can blow up IE if invoked prior to the window load event
        // while rendering a table.  It is possible there are other scenarios 
        // that would cause this to happen as well.
        body.insertBefore(div, body.firstChild);
    }
  },
  
  b4StartDrag: function(x, y) {
    // Reset in case reused
    YAHOO.util.Dom.setStyle(this.getDragEl(), 'opacity', '0.5');
    YAHOO.util.Dom.setStyle(this.getDragEl(), 'z-index', '999');
    this.showFrame(x, y);
    this.invalidDrop = false;
  },

  onInvalidDrop: function(e) {
    this.invalidDrop = true;
  },

  endDrag: function(e) {
    if (this.invalidDrop) {
      var DOM = YAHOO.util.Dom;
      var lel = this.getEl();
      var del = this.getDragEl();
      
      // Show the drag frame briefly so we can get its position
      DOM.setStyle(del, "visibility", ""); 

      left_offset = DOM.getX(del) - DOM.getX(lel);
      top_offset = DOM.getY(del) - DOM.getY(lel);
      var dur = Math.sqrt(Math.abs(top_offset^2)+Math.abs(left_offset^2))*0.02;      
      new YAHOO.util.Motion(del, {points: { from: [DOM.getX(del), DOM.getY(del)], to: [DOM.getX(lel), DOM.getY(lel)] } }, 1, YAHOO.util.Easing.easeOut).animate();
      new YAHOO.util.Anim(del, { opacity: { to: 0.2 }, zIndex: { to: -1 } }).animate();      
    }
  }
});

function add_draggable_for(recordId, recordName) {
    YAHOO.util.Event.onDOMReady(function() { 
      d = new ScrollingTableDDProxy('team_' + recordId + '_row', recordName, { 
        dragElId: 'team_' + recordId + '_row-proxy',
        resizeFrame: false
      });
      
      d.autoScroll = function(x, y, h, w) {

          if (this.scroll) {
            recordsDiv = $('records');
            recordsX = YAHOO.util.Dom.getX(recordsDiv);
            recordsY = YAHOO.util.Dom.getY(recordsDiv);
            

              // The client height
              var clientH = recordsDiv.getHeight();

              // The client width
              var clientW = recordsDiv.getWidth();

              // The amt scrolled down
              var st = this.DDM.getScrollTop();

              // The amt scrolled right
              var sl = this.DDM.getScrollLeft();

              // Location of the bottom of the element
              var bot = h + y;

              // Location of the right of the element
              var right = w + x;

              // The distance from the cursor to the bottom of the visible area, 
              // adjusted so that we don't scroll if the cursor is beyond the
              // element drag constraints
              var toBot = (clientH + st - y - this.deltaY);

              // The distance from the cursor to the right of the visible area
              var toRight = (clientW + sl - x - this.deltaX);


              // How close to the edge the cursor must be before we scroll
              // var thresh = (document.all) ? 100 : 40;
              var thresh = 40;

              // How many pixels to scroll per autoscroll op.  This helps to reduce 
              // clunky scrolling. IE is more sensitive about this ... it needs this 
              // value to be higher.
              var scrAmt = (document.all) ? 80 : 30;

              // Scroll down if we are near the bottom of the visible page and the 
              // obj extends below the crease
              if ( bot > clientH && toBot < thresh ) { 
                  recordsDiv.scrollTo(sl, st + scrAmt); 
              }

              // Scroll up if the window is scrolled down and the top of the object
              // goes above the top border
              if ( y < st && st > 0 && y - st < thresh ) { 
                  recordsDiv.scrollTo(sl, st - scrAmt); 
              }

              // Scroll right if the obj is beyond the right border and the cursor is
              // near the border.
              if ( right > clientW && toRight < thresh ) { 
                  recordsDiv.scrollTo(sl + scrAmt, st); 
              }

              // Scroll left if the window has been scrolled to the right and the obj
              // extends past the left border
              if ( x < sl && sl > 0 && x - sl < thresh ) { 
                  recordsDiv.scrollTo(sl - scrAmt, st);
              }
          }
      }
      
            // d.onDrag = function(e) {
      //   x = YAHOO.util.Event.getPageX(e);
      //   y = YAHOO.util.Event.getPageY(e);
      //   records = YAHOO.util.Dom.get("records");
      //   recordsX = YAHOO.util.Dom.getX(records);
      //   recordsY = YAHOO.util.Dom.getY(records);
      //   if (y >= recordsY && y < recordsY + 8) {
      //     records.scrollTop = records.scrollTop - 8;
      //   }
      //   if (y > recordsY + records.getHeight() - 8 && y <= recordsY + records.getHeight()) {
      //     records.scrollTop = records.scrollTop + 8;
      //   }
      // }
      
      d.onDragEnter = function (e, id) {
        YAHOO.util.Dom.addClass(id, "draggingOver");
      }
      
      d.onDragOut = function (e, id) {
        YAHOO.util.Dom.removeClass(id, "draggingOver");
      }
  
      d.onDragDrop = function(e, id) {
        x = YAHOO.util.Event.getPageX(e);
        y = YAHOO.util.Event.getPageY(e);
        recordsX = YAHOO.util.Dom.getX("records");
        recordsY = YAHOO.util.Dom.getY("records");
        if (y < recordsY || (y > recordsY + recordsDiv.getHeight())) {
          return;
        }
        
        YAHOO.util.DragDropMgr.lock();
        YAHOO.util.Dom.removeClass(id, "draggingOver");
        
        $(id).addClassName("disabled");
        new Effect.Opacity(id, { from: 1.0, to: 0.5, duration: 0.5 });
        new Effect.Opacity(this.getEl().id, { from: 1.0, to: 0.5, duration: 0.5 });
        new Ajax.Request('/admin/teams/merge?target_id=' + idRegex.exec(id), 
                         { asynchronous:true, 
                           evalScripts:true, 
                           parameters:'id=' + encodeURIComponent(idRegex.exec(this.getEl().id))
                          }
                         );

      }
    });
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

function captureClick(recordId) {
  row = $('team_' + recordId + '_row');
  row.onclick = clicked;
  if (row.captureEvents) row.captureEvents(Event.CLICK);
}

// TODO Fix flash messages makes table too tall
// TODO Throws JavaScript error in IE
// TODO Use attached event handler or something
// TODO Smarter calculation of height
// TODO Make this more effecient
function resizeScrollingTable() {
  // records is reserved word in IE?
  recordsDiv = $('records');
  if (recordsDiv == undefined) return;
  
  viewportHeight = YAHOO.util.Dom.getViewportHeight();
  if (viewportHeight < 100) {
    recordsDiv.setStyle({ height: 'auto' });
  }
  else {
    newHeight = viewportHeight - 276;
    if (newHeight < 50) newHeight = 50;
    recordsDiv.setStyle({ height: newHeight + 'px' });
  }
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
