import axios from 'axios'

const http = axios.create({
  baseURL: '/api',
  timeout: 10000,
  headers: { 'Content-Type': 'application/json' }
})

http.interceptors.response.use(
  (res) => res.data,
  (err) => {
    const message = err.response?.data?.message || err.message || '系統錯誤'
    return Promise.reject(new Error(message))
  }
)

export const userApi = {
  getAll: () => http.get('/users')
}

export const favoriteApi = {
  getList:  (userId)         => http.get('/favorites', { params: { userId } }),
  add:      (data)           => http.post('/favorites', data),
  update:   (sn, userId, data) => http.put(`/favorites/${sn}`, data, { params: { userId } }),
  delete:   (sn)             => http.delete(`/favorites/${sn}`)
}
