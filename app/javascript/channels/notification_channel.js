import consumer from "./consumer"

consumer.subscriptions.create("NotificationChannel", {
    received(data) {
        $.gritter.add({
            title: 'Proof is approved!',
            text: data.message,
            time: '5000',
            close_icon: 'l-arrows-remove s16',
            class_name: 'info-notice'
        });
    }
})

