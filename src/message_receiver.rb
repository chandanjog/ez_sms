require 'ruboto/broadcast_receiver'
import "android.util.Log"
import "android.telephony.SmsMessage"
import "java.util.ArrayList"
import "java.util.List"
import "org.apache.http.HttpEntity"
import "org.apache.http.HttpResponse"
import "org.apache.http.HttpStatus"
import "org.apache.http.NameValuePair"
import "org.apache.http.client.ClientProtocolException"
import "org.apache.http.client.HttpClient"
import "org.apache.http.client.entity.UrlEncodedFormEntity"
import "org.apache.http.client.methods.HttpPost"
import "org.apache.http.client.methods.HttpGet"
import "org.apache.http.client.utils.URLEncodedUtils"
import "org.apache.http.impl.client.DefaultHttpClient"
import "org.apache.http.message.BasicNameValuePair"
import "org.apache.http.util.EntityUtils"

# will get called whenever the BroadcastReceiver receives an intent (whenever onReceive is called)

$identifier = "EZSMS"
$target_url = "http://192.168.1.4:3000/response/123/EZSMS"

RubotoBroadcastReceiver.new_with_callbacks do
  def on_receive(context, intent)
    messages = get_messages_from_intent(intent)
    messages.each do |sms|
      
      msg_body = sms.get_display_message_body() 
      msg_sender = sms.get_display_originating_address() 
      Log.v "SMS_GW", msg_body
      Log.v "SMS_GW", msg_sender 
      Log.v "SMS_GW", $identifier 
      Log.v "SMS_GW", $target_url
      Log.v "SMS_GW", msg_body.include?($identifier).to_s
      
      if(msg_body.include?($identifier))
        forward_msg(msg_sender, msg_body, $target_url)
      end
    end
  end

  def get_messages_from_intent(intent)
    pdus = intent.get_extras.get("pdus")
    messages = []
    pdus.each do |item| 
      messages << SmsMessage.create_from_pdu(item)    
    end
    messages
  end

  def forward_msg(sender, body, target_url)
    Log.v "SMS_GW", "In forward msg"
    params = ArrayList.new
    params.add(BasicNameValuePair.new("phone_number",sender))
    params.add(BasicNameValuePair.new("comment",body))
    post = HttpPost.new(target_url)
    post.set_entity(UrlEncodedFormEntity.new(params))
    client = DefaultHttpClient.new
    
    response = client.execute(post)
    
  end

end

