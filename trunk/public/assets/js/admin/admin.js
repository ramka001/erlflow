(function(){
    YAHOO.util.Event.onDOMReady(function(){
        MainMenu();
        WelcomePanel();
    });
    
    function MainMenu(){
        function NewProcess_onClick(){
            ProcessesPanel();
        };
        
        var aItemData = [{
            text: "<em id=\"yahoolabel\">ErlFlow!</em>",
            submenu: {
                id: "yahoo",
                itemdata: ["About ErlFlow!", "Preferences"]
            }
        
        }, {
            text: "Archivo",
            submenu: {
                id: "filemenu",
                itemdata: [{
                    text: "Nuevo proceso...",
                    helptext: "Ctrl + P",
                    onclick: {
                        fn: NewProcess_onClick
                    }
                }, {
                    text: "Editar procesos...",
                    helptext: "Ctrl + E",
                }, {
                    text: "Editar participantes...",
                    helptext: "Ctrl + U"
                }]
            }
        
        }, {
            text: "Ver",
            submenu: {
                id: "viewmenu",
                itemdata: [[{
                    text: "Procesos",
                    helptext: "Ctrl + V"
                }, {
                    text: "Registro de sucesos",
                    helptext: "Ctrl + Y",
                }], [{
                    text: "Rendimiento",
                    helptext: "Ctrl + X",
                }]]
            }
        
        }, {
            text: "Herramientas",
            submenu: {
                id: "toolsmenu",
                itemdata: [[{
                    text: "Descargar",
                    helptext: "Ctrl + Z",
                    submenu: {
                        id: "descargar",
                        itemdata: ["Editor de procesos", "Editor de reportes"]
                    }
                }]]
            }
        
        }, "Ay&uacute;da"];
        
        var oMenuBar = new YAHOO.widget.MenuBar("mymenubar", {
            lazyload: true,
            itemdata: aItemData
        });
        
        oMenuBar.render(document.body);
    };
    
    function WelcomePanel(){
        var oPanel = new YAHOO.widget.Panel("welcomeinfo", {
            constraintoviewport: true,
            fixedcenter: true,
            width: "400px",
            zIndex: 1
        });
        
        oPanel.setHeader("C&oacute;nsola de Administraci&oacute;n de ErlFlow");
        oPanel.setBody("Bienvenido a la c&oacute;nsola de administraci&oacute;n de ErlFlow.<br>Aqu&iacute; Ud. podr&aacute; configurar los par&aacute;metros de ejecuci&oacute;n del sistema. Si no est&aacute; seguro de lo que est&aacute; haciendo, por favor contacte al Administrador del Sistema.");
        oPanel.render(document.body);
    }
    function ProcessesPanel(){
		var oPanel = new YAHOO.widget.Panel("processselect", {
            constraintoviewport: true,
            fixedcenter: false,
            width: "400px",
            zIndex: 1,
			xy:[20,40]
        });
        
        oPanel.setHeader("Procesos configurados en Erlflow.");
        oPanel.setBody("<div id='processesDiv' align='left'></div>");
        oPanel.render(document.body);
		YAHOO.util.Get.script('/assets/js/ef/nets_table.js');
  
    }
})();
