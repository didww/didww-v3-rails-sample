import { createConsumer } from '@rails/actioncable'

if (!window.App) window.App = {}
App.cable = createConsumer()
