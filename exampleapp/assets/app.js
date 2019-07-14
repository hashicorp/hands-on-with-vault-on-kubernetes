var socket = io({ transports: ["websocket"] });

// Listen for messages
socket.on("message", function(message) {
  function showCount(record) {
    var secrets = message.secrets
    console.log(secrets)

    secretLen = secrets.length;

    text = "<p>";
    for (i = 0; i < secretLen; i++) {
      text += secrets[i].Username + "=" + secrets[i].Password + "\n";
    }
    text += "</p>";

    $("#config").html(text)
    $("#hostname").text(message.Messsage)
  }

  showCount(message);
});

socket.on("connect", function() {
  // Broadcast a message
  function broadcastMessage() {
    socket.emit("send", {"message":"get count"}, function(result) {
      // Silent success, reload again
      setTimeout(broadcastMessage, 200) // In milliseconds
    });
  }
  broadcastMessage();
});
