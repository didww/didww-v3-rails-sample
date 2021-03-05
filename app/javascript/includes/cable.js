import { createConsumer } from "@rails/actioncable"

if (!window.App) window.App = {}
window.App.cable = createConsumer()
