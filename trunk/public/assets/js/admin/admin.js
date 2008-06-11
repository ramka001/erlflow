(function(){

    YAHOO.util.Event.onDOMReady(function(){
        MainMenu();
        WelcomePanel();
        LogviewerPanel();
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
                    id: "logviewer",
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
        YAHOO.log('Rendering main menu.', 'info', 'admin.js');
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
        YAHOO.log('Rendering welcome panel.', 'info', 'admin.js');
        oPanel.render(document.body);
    }
    
    function LogviewerPanel(){
        var oPanel = new YAHOO.widget.Panel("logviewerpanel", {
            constraintoviewport: true,
            fixedcenter: false,
            width: "350px",
            zIndex: 1,
            xy: [850, 40]
        });
        
        oPanel.setHeader("Visor de sucesos.");
        oPanel.setBody("<div id='logviewer' align='left'></div>");
        YAHOO.log('Rendering logviewer panel.', 'info', 'admin.js');
        oPanel.render(document.body);
        var loader = new YAHOO.util.YUILoader();
        loader.insert({
            require: ['fonts', 'dragdrop', 'logger'],
            base: '../../build/',
            
            onSuccess: function(loader){
                // Put a LogReader on your page
                this.myLogReader = new YAHOO.widget.LogReader("logviewer", {
                    logReaderEnabled: true,
                    newestOnTop: true
                });
            }
        });
    }
    
    function ProcessesPanel(){
        var oPanel = new YAHOO.widget.Panel("processselect", {
            constraintoviewport: true,
            fixedcenter: false,
            width: "400px",
            zIndex: 1,
            xy: [20, 40]
        });
        
        oPanel.setHeader("Procesos configurados en Erlflow.");
        oPanel.setBody("<div id='processesDiv'></div>");
        YAHOO.log('Rendering processes panel.', 'info', 'admin.js');
        oPanel.render(document.body);
        YAHOO.util.Get.script('/assets/js/ef/nets_table.js');
        
    }
})();
