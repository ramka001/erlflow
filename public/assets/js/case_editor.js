(function(){
    YAHOO.log('case_editor.js file loaded', 'info', 'case_editor.js');
    YAHOO.log('Inject some HTML for the Compose Window', 'info', 'case_editor.js');
    //YAHOO.util.Dom.get('composeViewEl').innerHTML = '<div id="top2"><div id="inboxToolbar"></div><div id="standard"></div></div><div id="center2"><div class="yui-layout-bd"><div id="preview"><p><strong>Got your eye on one of those messages up there?</strong></p><p>To view your message down here in this handy Reading pane, just click on it.</p></div></div></div>';
    YAHOO.util.Dom.get('composeViewEl').innerHTML = '<div id="composeBarWrap"><div id="composeBar"></div><div id="caseEditorView"></div></div>';
    //Use loader to load the Editor
    var loader = new YAHOO.util.YUILoader({
        base: '../../build/',
        require: ['autocomplete', 'editor'],
        ignore: ['containercore'],
        onSuccess: function(){
            YAHOO.log('Create a Toolbar above the To/From Fields', 'info', 'case_editor.js');
            erlflow.app.composeToolbar = new YAHOO.widget.Toolbar('composeBar', {
                buttons: [{
                    id: 'tb_delete',
                    type: 'push',
                    label: 'Send',
                    value: 'send'
                }, {
                    id: 'tb_reply',
                    type: 'push',
                    label: 'Attach',
                    value: 'attach'
                }, {
                    id: 'tb_forward',
                    type: 'push',
                    label: 'Save Draft',
                    value: 'savedraft'
                }, {
                    id: 'tb_forward',
                    type: 'push',
                    label: 'Spelling',
                    value: 'spelling'
                }, {
                    id: 'tb_forward',
                    type: 'push',
                    label: 'Cancel',
                    value: 'cancel'
                }]
            });
            //Show an alert message with the button they clicked            
            erlflow.app.composeToolbar.on('buttonClick', function(ev){
                erlflow.app.alert('You clicked: ' + ev.button.label);
            });
            
            erlflow.app.destroyEditor = function(){
                YAHOO.log('Destroying the Editor instance and HTML', 'info', 'editor.js');
                erlflow.app.editor = null;
            };
            var callback = {
                success: function(oResponse){
                    YAHOO.log("XHR transaction was successful.", "info", "example");
                    YAHOO.log(oResponse.responseText);
                    var oResults = YAHOO.lang.JSON.parse(oResponse.responseText);
                    erlflow.app.caseEditorView = new YAHOO.widget.Module("caseEditorView");
            		erlflow.app.caseEditorView.setBody("This is a dynamically generated Module: " + oResponse.responseText);
            		erlflow.app.caseEditorView.render();
                    /*for (var i = 0, j = oResults.networks.length; i < j; i++) {
                        var obj = new Object();
                        obj.id = oResults.networks[i].id;
                        obj.label = oResults.networks[i].name;
                        var tempNode = new YAHOO.widget.TextNode(obj, node, false);
                        tempNode.isLeaf = true;
                    }*/
                    
                    //oResponse.argument.fnLoadComplete();
                },
                
                failure: function(oResponse){
                    YAHOO.log("Failed to process XHR transaction.", "info", "example");
                },
                timeout: 7000
            };
			var sUrl = "/erlflow/net/" + erlflow.app.new_case.case_id;
            YAHOO.util.Connect.asyncRequest('GET', sUrl, callback);
            
        }
    });
    //Have loader only insert the js files..
    loader.insert({}, 'js');
})();
