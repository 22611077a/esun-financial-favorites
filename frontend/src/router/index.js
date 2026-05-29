import { createRouter, createWebHistory } from 'vue-router'
import FavoriteView from '../views/FavoriteView.vue'

const routes = [
  { path: '/', redirect: '/favorites' },
  { path: '/favorites', component: FavoriteView, meta: { title: '金融商品喜好管理' } }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to) => {
  document.title = to.meta.title ? `${to.meta.title} | 玉山銀行` : '玉山銀行'
})

export default router
