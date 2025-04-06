using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace gui
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        // Import necessary Windows API functions for positioning the window
        [DllImport("user32.dll")]
        private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int x, int y, int width, int height, uint uFlags);

        [DllImport("user32.dll")]
        private static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll")]
        private static extern IntPtr GetConsoleWindow();

        private void RunPowerShellTI(string appPath)
        {
            string scriptPath = ExtractEmbeddedScript("gui.untrusted1nstaller-runas.ps1");

            if (string.IsNullOrEmpty(scriptPath) || !File.Exists(scriptPath))
            {
                MessageBox.Show("Failed to extract the PowerShell script.", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            string psCommand = $"-ExecutionPolicy Bypass -File \"{scriptPath}\" -ApplicationPath \"{appPath}\"";

            ProcessStartInfo psi = new ProcessStartInfo
            {
                FileName = "powershell.exe",
                Arguments = psCommand,
                UseShellExecute = false,
                CreateNoWindow = false,  // Make the PowerShell window visible
                WindowStyle = ProcessWindowStyle.Normal
            };

            try
            {
                Process powerShellProcess = Process.Start(psi);

                if (powerShellProcess != null)
                {
                    powerShellProcess.EnableRaisingEvents = true;
                    powerShellProcess.Exited += (sender, e) =>
                    {
                        MessageBox.Show("PowerShell process finished.");
                    };
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to run as TrustedInstaller:\n{ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }


        private string? ExtractEmbeddedScript(string resourceName)
        {
            string tempFilePath = Path.Combine(Path.GetTempPath(), "untrusted1nstaller_runas.ps1");

            try
            {
                using (Stream? stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(resourceName))
                {
                    if (stream == null)
                        throw new Exception("Resource not found.");

                    using (FileStream fileStream = new FileStream(tempFilePath, FileMode.Create, FileAccess.Write))
                    {
                        stream.CopyTo(fileStream);
                    }
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to extract embedded resource:\n{ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return null;
            }

            return tempFilePath;
        }

        private void btnLaunchCMD_Click(object sender, EventArgs e)
        {
            RunPowerShellTI(@"C:\Windows\System32\cmd.exe");
        }

        private void btnBrowse_Click(object sender, EventArgs e)
        {
            using (OpenFileDialog ofd = new OpenFileDialog())
            {
                ofd.Filter = "Executable Files (*.exe)|*.exe";
                ofd.Title = "Choose an application to run as TrustedInstaller";

                if (ofd.ShowDialog() == DialogResult.OK)
                {
                    txtAppPath.Text = ofd.FileName;
                }
            }
        }

        private void btnRunCustom_Click(object sender, EventArgs e)
        {
            string path = txtAppPath.Text.Trim();
            if (!string.IsNullOrWhiteSpace(path) && File.Exists(path))
            {
                RunPowerShellTI(path);
            }
            else
            {
                MessageBox.Show("Please enter a valid path to an executable.", "Warning", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }
    }
}
