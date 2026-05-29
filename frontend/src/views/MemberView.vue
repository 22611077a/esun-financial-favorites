<template>
  <div class="page">
    <div class="page-header">
      <h1>會員管理</h1>
      <button class="btn btn-primary" @click="openForm()">+ 新增會員</button>
    </div>

    <!-- 錯誤訊息 -->
    <div v-if="store.error" class="alert alert-error">{{ store.error }}</div>

    <!-- 載入中 -->
    <div v-if="store.loading" class="loading">載入中...</div>

    <!-- 會員表格 -->
    <table v-else class="table">
      <thead>
        <tr>
          <th>ID</th><th>姓名</th><th>Email</th><th>電話</th><th>操作</th>
        </tr>
      </thead>
      <tbody>
        <tr v-if="store.members.length === 0">
          <td colspan="5" style="text-align:center;color:#888">尚無資料</td>
        </tr>
        <tr v-for="m in store.members" :key="m.id">
          <td>{{ m.id }}</td>
          <td>{{ m.name }}</td>
          <td>{{ m.email }}</td>
          <td>{{ m.phone }}</td>
          <td>
            <button class="btn btn-sm btn-secondary" @click="openForm(m)">編輯</button>
            <button class="btn btn-sm btn-danger"    @click="confirmDelete(m)">刪除</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- 新增 / 編輯 Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal">
        <h2>{{ editing ? '編輯會員' : '新增會員' }}</h2>
        <form @submit.prevent="submitForm">
          <div class="form-group">
            <label>姓名 *</label>
            <input v-model="form.name" placeholder="請輸入姓名" required />
          </div>
          <div class="form-group">
            <label>Email *</label>
            <input v-model="form.email" type="email" placeholder="請輸入 Email" required />
          </div>
          <div class="form-group">
            <label>電話</label>
            <input v-model="form.phone" placeholder="請輸入電話" />
          </div>
          <div v-if="formError" class="alert alert-error">{{ formError }}</div>
          <div class="modal-actions">
            <button type="button" class="btn btn-secondary" @click="showModal = false">取消</button>
            <button type="submit" class="btn btn-primary" :disabled="submitting">
              {{ submitting ? '處理中...' : '確認' }}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useMemberStore } from '../stores/memberStore.js'

const store = useMemberStore()

const showModal  = ref(false)
const editing    = ref(null)
const form       = ref({ name: '', email: '', phone: '' })
const formError  = ref('')
const submitting = ref(false)

onMounted(() => store.fetchAll())

function openForm(member = null) {
  editing.value = member
  form.value = member
    ? { name: member.name, email: member.email, phone: member.phone || '' }
    : { name: '', email: '', phone: '' }
  formError.value = ''
  showModal.value = true
}

async function submitForm() {
  submitting.value = true
  formError.value = ''
  try {
    if (editing.value) {
      await store.update(editing.value.id, form.value)
    } else {
      await store.create(form.value)
    }
    showModal.value = false
  } catch (e) {
    formError.value = e.message
  } finally {
    submitting.value = false
  }
}

async function confirmDelete(member) {
  if (!confirm(`確定刪除「${member.name}」？`)) return
  try {
    await store.remove(member.id)
  } catch (e) {
    alert(e.message)
  }
}
</script>

<style scoped>
.page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
h1 { font-size: 1.5rem; color: #1a3c6e; }

.table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,.1); }
.table th { background: #1a3c6e; color: #fff; padding: 12px 16px; text-align: left; font-weight: 600; }
.table td { padding: 12px 16px; border-bottom: 1px solid #eee; }
.table tr:last-child td { border-bottom: none; }
.table tr:hover td { background: #f0f4ff; }

.btn { padding: 8px 16px; border: none; border-radius: 6px; cursor: pointer; font-size: .9rem; transition: opacity .2s; }
.btn:hover { opacity: .85; }
.btn:disabled { opacity: .5; cursor: not-allowed; }
.btn-primary   { background: #1a3c6e; color: #fff; }
.btn-secondary { background: #6c757d; color: #fff; }
.btn-danger    { background: #dc3545; color: #fff; }
.btn-sm        { padding: 4px 10px; font-size: .82rem; margin-right: 4px; }

.loading { text-align: center; padding: 40px; color: #888; }
.alert { padding: 10px 14px; border-radius: 6px; margin-bottom: 12px; }
.alert-error { background: #fff0f0; color: #c0392b; border: 1px solid #f5c6cb; }

.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,.4); display: flex; align-items: center; justify-content: center; z-index: 100; }
.modal { background: #fff; border-radius: 10px; padding: 28px; width: 420px; max-width: 95vw; box-shadow: 0 8px 32px rgba(0,0,0,.2); }
.modal h2 { margin-bottom: 20px; color: #1a3c6e; }
.form-group { margin-bottom: 16px; }
.form-group label { display: block; margin-bottom: 6px; font-weight: 500; font-size: .9rem; }
.form-group input { width: 100%; padding: 8px 12px; border: 1px solid #ccc; border-radius: 6px; font-size: .95rem; }
.form-group input:focus { outline: none; border-color: #1a3c6e; box-shadow: 0 0 0 2px rgba(26,60,110,.15); }
.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
</style>
