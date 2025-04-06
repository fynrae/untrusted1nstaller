namespace gui
{
    partial class Form1
    {
        private System.ComponentModel.IContainer components = null;
        private System.Windows.Forms.Button btnLaunchCMD;
        private System.Windows.Forms.TextBox txtAppPath;
        private System.Windows.Forms.Button btnBrowse;
        private System.Windows.Forms.Button btnRunCustom;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
                components.Dispose();
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            this.btnLaunchCMD = new System.Windows.Forms.Button();
            this.txtAppPath = new System.Windows.Forms.TextBox();
            this.btnBrowse = new System.Windows.Forms.Button();
            this.btnRunCustom = new System.Windows.Forms.Button();
            this.SuspendLayout();

            // 
            // btnLaunchCMD
            // 
            this.btnLaunchCMD.Location = new System.Drawing.Point(20, 20);
            this.btnLaunchCMD.Name = "btnLaunchCMD";
            this.btnLaunchCMD.Size = new System.Drawing.Size(200, 30);
            this.btnLaunchCMD.Text = "Launch CMD as TI";
            this.btnLaunchCMD.UseVisualStyleBackColor = true;
            this.btnLaunchCMD.Click += new System.EventHandler(this.btnLaunchCMD_Click);

            // 
            // txtAppPath
            // 
            this.txtAppPath.Location = new System.Drawing.Point(20, 70);
            this.txtAppPath.Name = "txtAppPath";
            this.txtAppPath.Size = new System.Drawing.Size(350, 23);

            // 
            // btnBrowse
            // 
            this.btnBrowse.Location = new System.Drawing.Point(380, 68);
            this.btnBrowse.Name = "btnBrowse";
            this.btnBrowse.Size = new System.Drawing.Size(80, 25);
            this.btnBrowse.Text = "Browse...";
            this.btnBrowse.UseVisualStyleBackColor = true;
            this.btnBrowse.Click += new System.EventHandler(this.btnBrowse_Click);

            // 
            // btnRunCustom
            // 
            this.btnRunCustom.Location = new System.Drawing.Point(20, 110);
            this.btnRunCustom.Name = "btnRunCustom";
            this.btnRunCustom.Size = new System.Drawing.Size(200, 30);
            this.btnRunCustom.Text = "Run Custom App as TI";
            this.btnRunCustom.UseVisualStyleBackColor = true;
            this.btnRunCustom.Click += new System.EventHandler(this.btnRunCustom_Click);

            // 
            // Form1
            // 
            this.ClientSize = new System.Drawing.Size(480, 170);
            this.Controls.Add(this.btnLaunchCMD);
            this.Controls.Add(this.txtAppPath);
            this.Controls.Add(this.btnBrowse);
            this.Controls.Add(this.btnRunCustom);
            this.Name = "Form1";
            this.Text = "untrusted1nstaller GUI";
            this.ResumeLayout(false);
            this.PerformLayout();
        }
    }
}
