import consumer from "./consumer"

consumer.subscriptions.create("NotificationChannel", {
    received(data) {
        console.log(data)
        $.gritter.add({
            title: `${data.type} notification`,
            text: data.message || `${data.type} is approved`,
            time: '5000',
            close_icon: 'l-arrows-remove s16',
            class_name: data.status == 'completed' ? 'success-notice' :
                        data.status == 'canceled' ? 'error-notice' : 'info-notice'
        });
    }
})

