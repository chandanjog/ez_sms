require 'ruboto/broadcast_receiver'
import "android.util.Log"
import "android.telephony.SmsMessage"

# will get called whenever the BroadcastReceiver receives an intent (whenever onReceive is called)

identifier = "EZSMS"
targetURL = "localhost:3000"

RubotoBroadcastReceiver.new_with_callbacks do
  def on_receive(context, intent)
    messages = get_messages_from_intent(intent)
    messages.each do |sms|
      Log.v "SMS_BODY", sms.get_display_message_body() 
      Log.v "SMS_SENDER", sms.get_display_originating_address() 
    end
    #Log.v "MYAPP", intent.getExtras.to_s
  end

  def get_messages_from_intent(intent)
    pdus = intent.get_extras.get("pdus")
    messages = []
    pdus.each do |item| 
      messages << SmsMessage.create_from_pdu(item)    
    end
    messages
  end

end

