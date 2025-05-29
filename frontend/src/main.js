import { createApp } from 'vue';
import App from './App.vue';
import router from './router';
//import pinia from './stores'; // Assuming you named your Pinia instance 'pinia'

// Vuetify
import 'vuetify/styles'; // Global Vuetify styles
import { createVuetify } from 'vuetify';
import * as components from 'vuetify/components';
import * as directives from 'vuetify/directives';
import '@mdi/font/css/materialdesignicons.css'; // Material Design Icons

const vuetify = createVuetify({
  components,
  directives,
  // You can add theme customization here if needed
  // theme: {
  //   defaultTheme: 'light', // or 'dark'
  // },
});

const app = createApp(App);

app.use(router);
app.use(pinia);
app.use(vuetify); // Use Vuetify

app.mount('#app');

// import './assets/main.css'
// import '@mdi/font/css/materialdesignicons.css'; // Ensure you are using css-loader
// import { createApp } from 'vue'
// import { createPinia } from 'pinia'
//
// import App from './App.vue'
// import router from './router'
//
// const app = createApp(App)
//
// app.use(createPinia())
// app.use(router)
//
// app.mount('#app')
