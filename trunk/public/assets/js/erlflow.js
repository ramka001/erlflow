(function(){
    Erlflow = new Object();
			Erlflow.main = new Object();
            
            Erlflow.main.treeProcesses = function(){
            
                var tree, currentIconMode;
                
                function changeIconMode(){
                    var newVal = parseInt(this.value);
                    if (newVal != currentIconMode) {
                        currentIconMode = newVal;
                    }
                    buildTree();
                }
                
                function loadNodeData(node, fnLoadComplete){
                    var nodeLabel = encodeURI(node.label);
                    var sUrl = "erlflow/" + nodeLabel;
                    var callback = {
                        success: function(oResponse){
                            YAHOO.log("XHR transaction was successful.", "info", "example");
                            YAHOO.log(oResponse.responseText);
                            var oResults = YAHOO.lang.JSON.parse(oResponse.responseText);                            
                            
                            for (var i = 0, j = oResults.networks.length; i < j; i++) {
                                var tempNode = new YAHOO.widget.TextNode(oResults.networks[i].name, node, false);
								tempNode.isLeaf = true;
                            }
                            
                            oResponse.argument.fnLoadComplete();
                        },
                        
                        failure: function(oResponse){
                            YAHOO.log("Failed to process XHR transaction.", "info", "example");
                            oResponse.argument.fnLoadComplete();
                        },
                        argument: {
                            "node": node,
                            "fnLoadComplete": fnLoadComplete
                        },
                        timeout: 7000
                    };
                    
                    YAHOO.util.Connect.asyncRequest('GET', sUrl, callback);
                }
                
                function buildTree(){
                    tree = new YAHOO.widget.TreeView("processesDiv");
                    tree.setDynamicLoad(loadNodeData, currentIconMode);
                    var root = tree.getRoot();
                    
                    var aStates = ["Procesos"];
                    
                    for (var i = 0, j = aStates.length; i < j; i++) {
                        var tempNode = new YAHOO.widget.TextNode(aStates[i], root, false);
                    }
                    tree.draw();
                }
                
                
                return {
                    init: function(){
                        buildTree();
                    }
                    
                }
            }
            ();
            
            YAHOO.util.Event.onDOMReady(Erlflow.main.treeProcesses.init, Erlflow.main.treeProcesses, true);
})();
