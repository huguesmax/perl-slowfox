<!-- The variable "Zoiper" is used to keep reference about the Zoiper Web instance. It is going to hold the "Phone" object -->
    var Zoiper;
<!-- The variable "ActiveCall" is used to keep a reference to the current active "Call" object -->          
    var ActiveCall;
<!-- The function GetValue is a helper function used to get the value of a document element by its ID --> 
    function GetValue(name)
    {
      return document.getElementById(name).value;
    }
<!-- The function "Quit" is used to stop Zoiper Web, we will use it to delete the items we have created during the example -->                    
    function Quit()
    {
      Status("Quit() called");
      if (Zoiper != null)
      {
        Zoiper.DelContact("web demo");
        Zoiper.DelAccount("Sample");
      }
<!-- On Firefox new instances of the plugin are created before old ones are destroyed Because of this we must manually destroy the existing plugin -->
      document.getElementById('ZoiperA').innerHTML = "";
    }
<!-- The function "Hang" is a helper function and is used to hangup the "ActiveCall" that we keep reference of -->        
    function Hang()
    {
      if (null != ActiveCall)
      {
        ActiveCall.Hang();
        ActiveCall = null;
      }          
    }
<!-- The function "Dial" is used to dial a number entered by the user in the input field with ID="number". It also assigns the newly created "Call" object to the "ActiveCall" variable -->          
    function Dial()
    {
      ActiveCall = Zoiper.Dial(GetValue("number"));
    }
<!-- The function "Hold" is used to put the current active call on hold --> 
    function Hold()
    {
      if (null != ActiveCall)
        ActiveCall.Hold();
    }
<!-- The function "SendDTMFSequence" sends a sequence of dtmf digits entered in the input area named "dtmfsequence" --> 
    function SendDTMFSequence()
    {
      if (null != ActiveCall)
      {
        ActiveCall.SendDTMF(GetValue("dtmfsequence"));
      }  
    }    
<!-- The function "ShowAudioWizard" is used to show audio wizard dialog --> 
    function ShowAudioWizard()
    {
      if (null != Zoiper)
      {
        Zoiper.ShowAudioWizard();
      }
    }
<!-- The function "ShowLog" is used to show log dialog --> 
    function ShowLog()
    {
      if (null != Zoiper)
      {
        Zoiper.ShowLog();
      }
    }
<!-- The function "MuteSpeakerToggle" is used to enable and disable audio output --> 
    function MuteSpeakerToggle()
    {
      if (Zoiper.MuteSpeaker == "true")
        Zoiper.MuteSpeaker = "false";
      else            
        Zoiper.MuteSpeaker = "true";
    }

<!-- The function "MuteMicToggle" is used to enable and disable audio input --> 
    function MuteMicToggle()
    {
      if (Zoiper.MuteMicrophone == "true")
        Zoiper.MuteMicrophone = "false";
      else            
        Zoiper.MuteMicrophone = "true";
    }    
<!-- The function "Login" is used to login the user to the Zoiper Service. It uses the username and password provided by the user in the input fields "user" and "pass" -->          
    function Login()
    {
      var user = GetValue("user");
      var pass = GetValue("pass");
      Zoiper.Login(user,pass);
    }
<!-- The function "Logout" is used to logout the user from the Zoiper Service. -->          
    function Logout()
    {
      Zoiper.Logout();
    }
<!-- The function "Status" is used to show a status text in the element with ID="Status". It is used as a log function to show the state of the phone and what events are triggered -->                    
    function Status(text)
    {
      var node = document.getElementById("thelog");
      node.value += text + "\n";
    }
<!-- The function "OnZoiperReady" is the entry point for Zoiper Web usage. It is called by Zoiper Web when it is ready for use. It provides a reference to its "Phone" object which we assign to the "Zoiper" variable. We use it to make the initial setup -->          
    function OnZoiperReady(phone)
    {
<!-- We clear the log input box -->    
      document.getElementById("thelog").value = "";
<!-- We put the Zoiper Web instance reference to the global variable "Zoiper"-->    
      Zoiper = phone;
<!-- Here we allow other Zoiper Web instances in different processes to be loaded if necessary--> 
      Zoiper.AllowMultipleInstances();
<!-- We print the version of the Zoiper Web instance we are running -->      
      Status("Version : " + Zoiper.Version);
<!-- Here we get the "Config" object instance and put it in the variable named Config--> 
      var Config = Zoiper.GetConfig();
<!-- Here we change the SIP and IAX listening ports--> 
      Config.SetSIPIAXPorts("4569","5061");
<!-- Here we restrict the number of simultaneous calls allowed to 2 --> 
      Config.NumberOfCallsLimit("2");
<!-- Here we set some general configuration properties. We disable the popup menu on incoming calls  and we set the debug log to be  written to  “D:\” and enable it--> 
      Config.PopupMenuOnIncomingCall = "false";
      Config.DebugLogPath = "d:\\";
      Config.EnableDebugLog = "true";
<!-- Here we setup Zoiper Web not to ring when the user is already on the phone--> 
      Config.RingWhenTalking = "false";
<!-- Here we create or get an existing "Account" object called "Sample". The "Account" is going to use the SIP protocol -->                        
      Account = Zoiper.AddAccount("slowfox", "iax");
<!-- Here we set the "Account" properties -->                    
      Account.Host   = "XX.XX.XX.XX:4569";
      Account.CallerID = "WebZioper";
      Account.UserName = "username";
      Account.Password = "password";
<!-- Here we enable the STUN usage -->           
      Account.STUNHost = "";
      Account.STUNPort = "3478";
<!-- Here we enable the custom codec list and select only the GSM codec -->
      Account.AddCodec("iLBC 30");
<!-- Here we set the “Account” to use inband DTMF signals -->            
      Account.DTMFType = "media_inband";
<!-- Here we apply the so far set properties and register the "Account" --> 
      Account.Apply();
      Account.Register();
<!-- Here we enable the SIP header dump-->
      Account.SipHeaderDump("true"); 
<!-- Here we set a custom header named "testheader" to be send in the calls that are using this account. First we set it to "zoiperweb" then we clear it and then add two headers with the same name set to "value1" and "value2"-->
      Account.SipHeaderAdd("testheader","zoiperweb");
      Account.SipHeaderClear("testheader");
      Account.SipHeaderAdd("testheader","value1");
      Account.SipHeaderAdd("testheader","value2");
<!-- Here we select the "Sample" "Account" to be the active one -->            
      Zoiper.UseAccount("Sample");
<!-- Here we create a new "Contact" object with primary number "web demo" and set its properties -->
      var Contact         = Zoiper.AddContact("Hugues");
      Contact.Account     = "Money30";
      Contact.Display     = "Hugues BOUHANA";
      Contact.FirstName   = "Hugues";
      Contact.MiddleName  = "";
      Contact.LastName    = "BOUHANA";
      Contact.Country     = "France";
      Contact.City        = "Le Rouret";
      Contact.WorkPhone   = "1212";
      Contact.HomePhone   = "home";
      Contact.CellPhone   = "cell";
      Contact.FaxNumber   = "fax";
      Contact.Apply();
    }
<!-- Here we have a simple implementation of the available "Callback" functions -->
    function OnZoiperCallFail(call)
    {
      Status(call.Phone + " failed");
    }
    function OnZoiperCallRing(call)
    {
      Status(call.Phone + " ring");
    }
    function OnZoiperCallHang(call)
    {
      Status(call.Phone + " hang");
    }
    function OnZoiperCallHold(call)
    {
      Status(call.Phone + " hold");
    }
    function OnZoiperCallUnhold(call)
    {
      Status(call.Phone + " unhold");
    }
    function OnZoiperCallAccept(call)
    {
      Status(call.Phone + " accept");
    }
    function OnZoiperCallReject(call)
    {
      Status(call.Phone + " reject");
    }
    function OnZoiperCallIncoming(call)
    {
      Status(call.Phone + " incoming");
    }
    function OnZoiperAccountRegister(account)
    {
      Status(account.Name + " is registered");
    }
    function OnZoiperAccountUnregister(account)
    {
      Status(account.Name + " is unregistered");
    }
    function OnZoiperAccountRegisterFail(account)
    {
      Status(account.Name + " failed to register");
    }
    function OnZoiperContactStatus(contact,status)
    {
      Status(contact.Name + " is " + status);
    }
    function OnZoiperCallSipHeader(call,sip)
    {
   	   Status("SIP header counts: " + sip.Count);
<!-- This fragment of code demonstrates how to display a specific SIP header (in this case the "allow" header) -->
      var property = sip.Entry("allow");
      if (null != property)
      {
        for (var j=0; j<property.Count; j++)
        {
          Status(" Allow: " + property.Value(j));
        }
      }
<!-- This fragment of code demonstrates how to display all SIP headers -->
      for (var i=0; i<sip.Count; i++)
      {
        var property = sip.Entry(i);
        Status("Header label: " + property.Name);
        for (var j=0; j<property.Count; j++)
        {
          Status("     value: " + property.Value(j));
        }
      }
    }
