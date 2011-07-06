/**
 * This is a generated sub-class of _DBAuth.as and is intended for behavior
 * customization.  This class is only generated when there is no file already present
 * at its target location.  Thus custom behavior that you add here will survive regeneration
 * of the super-class. 
 **/
 
package it.ht.rcs.console.accounting.rest
{
  import com.adobe.serialization.json.JSON;
  
  import it.ht.rcs.console.DB;
  
  import mx.rpc.CallResponder;

public class DBAuth extends _Super_DBAuth implements IDBAuth
{
    /**
     * Override super.init() to provide any initialization customization if needed.
     */
    protected override function preInitializeService():void
    {
        super.preInitializeService();
        // Initialization customization goes here
    }
    
    public function DBAuth(host: String) {
      super();
      _serviceControl.baseURL = "https://" + host + ":4444/";
    }
    
    public function login(credentials:Object, onResult:Function, onFault:Function):void
    {
      var resp:CallResponder = DB.getCallResponder(onResult, onFault);
      resp.token = login_(JSON.encode(credentials));  
    }
    
    public function logout(onResult:Function=null, onFault:Function=null):void
    {
      var resp:CallResponder = DB.getCallResponder(onResult, onFault);
      resp.token = logout_(); 
    }
    
}

}
