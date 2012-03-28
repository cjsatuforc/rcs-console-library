package it.ht.rcs.console.alert.controller
{
  import flash.events.Event;
  import flash.events.TimerEvent;
  import flash.utils.Timer;
  
  import it.ht.rcs.console.DB;
  import it.ht.rcs.console.alert.model.Alert;
  import it.ht.rcs.console.controller.ItemManager;
  import it.ht.rcs.console.events.RefreshEvent;
  import it.ht.rcs.console.events.SessionEvent;
  import it.ht.rcs.console.push.PushController;
  import it.ht.rcs.console.push.PushEvent;
  
  import mx.collections.ArrayCollection;
  import mx.core.FlexGlobals;
  import mx.events.PropertyChangeEvent;
  import mx.rpc.events.ResultEvent;
  
  public class AlertManager extends ItemManager
  {
    
    public function AlertManager() { super(Alert); }
    
    private static var _instance:AlertManager = new AlertManager();
    public static function get instance():AlertManager { return _instance; }
    
    public function startAutorefresh():void
    {
      PushController.instance.addEventListener(PushEvent.ALERT, onAutorefresh);
      refresh();
    }
    
    public function stopAutorefresh():void
    {
      PushController.instance.removeEventListener(PushEvent.ALERT, onAutorefresh);
    }
    
    public function onAutorefresh(e:*):void
    {
      refresh();
    }
    
    override public function refresh():void
    {
      super.refresh();
      DB.instance.alert.all(onResult);
    }
    
    private function onResult(e:ResultEvent):void
    {
      clear();
      for each (var item:* in e.result.source)
        addItem(item);
      dispatchDataLoadedEvent();
    }
    
    override protected function onItemRemove(o:*):void
    { 
      DB.instance.alert.destroy(o);
    }
    
    override protected function onItemUpdate(event:*):void
    {
      var property:Object = new Object();
      property[event.property] = event.newValue is ArrayCollection ? event.newValue.source : event.newValue;
      DB.instance.alert.update(event.source, property);
    }
    
    public function addAlert(alert:Object, callback:Function):void
    {     
      DB.instance.alert.create(alert, function (e:ResultEvent):void {
        var a:Alert = e.result as Alert;
        addItem(a);
        callback(a);
      });
    }
    
    override protected function onLogout(e:SessionEvent):void
    {
      super.onLogout(e);
      stopCounters();
    }
    
    private var _alertCounter:Object = {value: NaN, style: 'info'};
    
    public function startCounters():void
    {
      FlexGlobals.topLevelApplication.addEventListener(RefreshEvent.REFRESH, onAlertEvent);
      PushController.instance.addEventListener(PushEvent.ALERT, onAlertEvent);
      
      /* the first refresh */
      onAlertEvent(null);
    }
    
    public function stopCounters():void
    {
      FlexGlobals.topLevelApplication.removeEventListener(RefreshEvent.REFRESH, onAlertEvent);
      PushController.instance.removeEventListener(PushEvent.ALERT, onAlertEvent);
    }
    
    public function refreshCounters():void
    {
      onAlertEvent(null);
    }
    
    private function onAlertEvent(e:Event):void
    {
      DB.instance.alert.counters(onAlertCounters);
    }
    
    private function onAlertCounters(e:ResultEvent):void
    {
      _alertCounter.value = e.result as int;
      _alertCounter.style = 'info';
      dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, 'alertCounter', null, _alertCounter));
    }
    
    [Bindable(event='propertyChange')]
    public function get alertCounter():Object
    {
      return _alertCounter;
    }

  }
  
}