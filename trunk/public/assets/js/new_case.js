(function(){
	var Dom = YAHOO.util.Dom,
        Event = YAHOO.util.Event;
		//YAHOO.util.Get.script('assets/js/case_editor.js');
    function init(){
    
        // Define various event handlers for Dialog
        var initCase = function(){
        
        };
        
        var handleSubmit = function(){
			this.hide();
            if (!erlflow.app.editor) {
                YAHOO.log('No editor present, add the tab', 'info', 'button.js');
                var cTab = new YAHOO.widget.Tab({
                    label: '<span class="close"></span><span class="icon"></span>Nuevo Caso',
                    id: 'composeView',
                    active: true,
                    contentEl: Dom.get('composeViewEl')
                });
                //Add the close button to the tab
                Event.on(cTab.get('labelEl').getElementsByTagName('span')[0], 'click', function(ev){
                    YAHOO.log('Closing the Editor tab and destroying the Editor instance', 'info', 'button.js');
                    Event.stopEvent(ev);
                    erlflow.app.tabView.set('activeTab', erlflow.app.tabView.get('tabs')[0]);
                    var cel = Dom.get('composeViewEl');
                    erlflow.app.destroyEditor();
                    erlflow.app.tabView.removeTab(cTab);
                    document.body.appendChild(cel);
                    
                });
                erlflow.app.tabView.addTab(cTab);
                YAHOO.log('Load the Editor', 'info', 'button.js');
                window.setTimeout(function(){
                    var transactionObj = YAHOO.util.Get.script('assets/js/case_editor.js', {
                        autopurge: true
                    });
                }, 0);
            }
            else {
                YAHOO.log('If there is an editor, then activate the proper tab', 'info', 'button.js');
                var t = erlflow.app.tabView.get('tabs');
                for (var i = 0; i < t.length; i++) {
                    if (t[i].get('id') == 'composeView') {
                        erlflow.app.tabView.set('activeTab', t[i]);
                    }
                }
            }
        };
        var handleCancel = function(){
            this.cancel();
        };
        var handleSuccess = function(o){
            var response = o.responseText;
            response = response.split("<!")[0];
            document.getElementById("resp").innerHTML = response;
        };
        var handleFailure = function(o){
            alert("Submission failed: " + o.status);
        };
        
        // Instantiate the Dialog
        erlflow.app.new_case = new YAHOO.widget.Dialog("new_case", {
            width: "30em",
            fixedcenter: true,
            visible: false,
            constraintoviewport: true,
            buttons: [{
                text: "Submit",
                handler: handleSubmit,
                isDefault: true,
				disabled: true
            }, {
                text: "Cancel",
                handler: handleCancel
            }]
        });
        
        // Validate the entries in the form to require that both first and last name are entered
        erlflow.app.new_case.validate = function(){
            var data = this.getData();
            if (data.firstname == "" || data.lastname == "") {
                alert("Please enter your first and last names.");
                return false;
            }
            else {
                return true;
            }
        };
        
        // Wire up the success and failure handlers
        erlflow.app.new_case.callback = {
            success: handleSuccess,
            failure: handleFailure
        };
        
        // Render the Dialog
        erlflow.app.new_case.render();
        
        YAHOO.util.Event.addListener("newButton", "click", erlflow.app.new_case.show, erlflow.app.new_case, true);
        //YAHOO.util.Event.addListener("hide", "click", erlflow.app.new_case.hide, YAHOO.erlflow.app.new_case, true);
        YAHOO.util.Get.script('/assets/js/ef/nets_tree.js');
    }
    
    YAHOO.util.Event.onDOMReady(init);
})();
