var wso = new ActiveXObject("Scripting.WindowSystemObject");
wso.EnableVisualStyles = true;

var form = wso.CreateForm(100, 100, 460, 500);
form.Text = "WSO + XNA Test - donen kare";
form.ClientWidth = 440;
form.ClientHeight = 440;

var ax = form.CreateActiveXControl(0, 0, 440, 440, "WsoXnaBridge.Renderer");

form.OnCloseQuery = function (sender, resultPtr) {
    resultPtr.Put(true);
};

form.Show();
wso.Run();
