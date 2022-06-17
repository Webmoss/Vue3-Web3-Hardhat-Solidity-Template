import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import VUpload from '../views/VUpload.vue';

// Async Component
const VAbout = () => import('../views/VAbout.vue');

const router = createRouter({
  scrollBehavior(to, from, savedPosition) {
    if (to.hash) {
      return window.scrollTo({
        top: document.querySelector(to.hash).offsetTop - 135,
        behavior: 'smooth',
      });
    } else {
      return savedPosition || { x: 0, y: 0 };
    }
  },
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: VUpload,
    },
    {
      path: '/',
      name: 'upload',
      component: VUpload,
    },
    {
      path: '/about',
      name: 'about',
      // route level code-splitting
      // this generates a separate chunk (About.[hash].js) for this route
      // which is lazy-loaded when the route is visited.
      component: VAbout,
    },
  ],
});

export default router;
