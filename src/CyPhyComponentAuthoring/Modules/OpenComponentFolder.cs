﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using CyPhy = ISIS.GME.Dsml.CyPhyML.Interfaces;
using META;
using System.IO;
using System.Diagnostics;
using System.Windows.Forms;

namespace CyPhyComponentAuthoring.Modules
{
    [CyPhyComponentAuthoringInterpreter.IsCATModule(ContainsCATmethod = true)]
    public class OpenComponentFolder : CATModule
    {
        public CyPhyGUIs.GMELogger Logger { get; set; }
        private bool Close_Dlg;

        [CyPhyComponentAuthoringInterpreter.CATName(
            NameVal = "Open Folder",
            DescriptionVal = "Locate the Component's resource folder on the disk, and open it in Windows Explorer.",
            RoleVal = CyPhyComponentAuthoringInterpreter.Role.Publish
            )
        ]
        public void OpenFolder(object sender, EventArgs e)
        {
            open_component_folder();

            // Close the calling dialog box if the module ran successfully
            if (Close_Dlg)
            {
                // calling object is a button
                Button callerBtn = (Button)sender;
                // the button is in a layout panel
                TableLayoutPanel innerTLP = (TableLayoutPanel)callerBtn.Parent;
                // the layout panel is a table within a table
                TableLayoutPanel outerTLP = (TableLayoutPanel)innerTLP.Parent;
                // the TLP is in the dialog box
                Form parentDB = (Form)outerTLP.Parent;
                parentDB.Close();
            }
        }

        void open_component_folder()
        {
            this.Logger = new CyPhyGUIs.GMELogger(CurrentProj, this.GetType().Name);

            CyPhy.Component comp = GetCurrentComp();
            var absPath = comp.GetDirectoryPath(ComponentLibraryManager.PathConvention.ABSOLUTE);

            if (false == Directory.Exists(absPath))
            {
                Logger.WriteError("Component path does not exist: {0}", absPath);
                clean_up(false);
                return;
            }

            // META-2517 Explorer doesn't like paths with mixed seperators, make them all the same
            string uniformabspath = absPath.Replace("\\", "/");
            try
            {
                Process.Start(@uniformabspath);
            }
            catch (Exception ex)
            {
                Logger.WriteError("Error opening Windows Explorer: {0}", ex.Message);
                clean_up(false);
                return;
            }

            clean_up(true);
        }

        // clean up loose ends on leaving this module
        void clean_up(bool close_dlg)
        {
            Close_Dlg = close_dlg;
            this.Logger.Dispose();
        }
    }
}
