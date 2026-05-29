<template>
  <div>
    <!-- 使用者選擇 -->
    <div class="card user-card">
      <label>選擇使用者：</label>
      <select v-model="selectedUserId" @change="loadFavorites">
        <option value="">-- 請選擇 --</option>
        <option v-for="u in users" :key="u.userId" :value="u.userId">
          {{ u.userName }}（{{ u.userId }}）
        </option>
      </select>
      <span v-if="currentUser" class="user-info">
        📧 {{ currentUser.email }} ｜ 帳號：{{ currentUser.account }}
      </span>
    </div>

    <!-- 功能區塊 -->
    <div v-if="selectedUserId" class="card">
      <div class="section-header">
        <h2>喜好金融商品清單</h2>
        <button class="btn btn-primary" @click="openAdd">＋ 新增喜好商品</button>
      </div>

      <!-- 錯誤訊息 -->
      <div v-if="error" class="alert alert-error">{{ error }}</div>

      <!-- 載入中 -->
      <div v-if="loading" class="loading">載入中...</div>

      <!-- 清單表格 -->
      <template v-else>
        <table class="table">
          <thead>
            <tr>
              <th>序號</th>
              <th>產品名稱</th>
              <th>產品價格</th>
              <th>手續費率</th>
              <th>購買數量</th>
              <th>扣款帳號</th>
              <th>總手續費</th>
              <th>預計扣款總額</th>
              <th>Email</th>
              <th>操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="favorites.length === 0">
              <td colspan="10" class="empty">尚無喜好商品，點選「新增」開始加入</td>
            </tr>
            <tr v-for="f in favorites" :key="f.sn">
              <td>{{ f.sn }}</td>
              <td><strong>{{ f.productName }}</strong></td>
              <td class="num">{{ formatMoney(f.price) }}</td>
              <td class="num">{{ formatRate(f.feeRate) }}</td>
              <td class="num">{{ f.purchaseQuantity }}</td>
              <td>{{ f.account }}</td>
              <td class="num fee">{{ formatMoney(f.totalFee) }}</td>
              <td class="num amount">{{ formatMoney(f.totalAmount) }}</td>
              <td class="email">{{ f.email }}</td>
              <td>
                <button class="btn btn-sm btn-edit"   @click="openEdit(f)">編輯</button>
                <button class="btn btn-sm btn-delete" @click="confirmDelete(f)">刪除</button>
              </td>
            </tr>
          </tbody>
          <tfoot v-if="favorites.length > 0">
            <tr>
              <td colspan="6" class="total-label">合計</td>
              <td class="num fee"><strong>{{ formatMoney(sumFee) }}</strong></td>
              <td class="num amount"><strong>{{ formatMoney(sumAmount) }}</strong></td>
              <td colspan="2"></td>
            </tr>
          </tfoot>
        </table>
      </template>
    </div>

    <!-- 新增 / 編輯 Modal -->
    <div v-if="showModal" class="modal-overlay" @click.self="showModal = false">
      <div class="modal">
        <h3>{{ editTarget ? '更改喜好金融商品' : '新增喜好金融商品' }}</h3>
        <form @submit.prevent="submitForm">
          <div class="form-row">
            <div class="form-group">
              <label>產品名稱 *</label>
              <input v-model="form.productName" placeholder="ex: 台積電 ETF" required maxlength="200" />
            </div>
          </div>
          <div class="form-row two-col">
            <div class="form-group">
              <label>產品價格 *</label>
              <input v-model="form.price" type="number" step="0.01" min="0.01" placeholder="ex: 100.00" required @input="calcPreview" />
            </div>
            <div class="form-group">
              <label>手續費率 * <small>(ex: 0.01 = 1%)</small></label>
              <input v-model="form.feeRate" type="number" step="0.0001" min="0" max="1" placeholder="ex: 0.01" required @input="calcPreview" />
            </div>
          </div>
          <div class="form-row two-col">
            <div class="form-group">
              <label>扣款帳號 *</label>
              <input v-model="form.account" placeholder="ex: 1111999666" required maxlength="20" pattern="[0-9]+" title="只能輸入數字" />
            </div>
            <div class="form-group">
              <label>購買數量 *</label>
              <input v-model="form.purchaseQuantity" type="number" min="1" step="1" placeholder="ex: 10" required @input="calcPreview" />
            </div>
          </div>

          <!-- 即時預覽 -->
          <div class="preview" v-if="preview.totalAmount > 0">
            <div class="preview-item">
              <span>總手續費</span>
              <strong class="fee">{{ formatMoney(preview.totalFee) }}</strong>
            </div>
            <div class="preview-item">
              <span>預計扣款總金額</span>
              <strong class="amount">{{ formatMoney(preview.totalAmount) }}</strong>
            </div>
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
import { ref, computed, onMounted } from 'vue'
import { userApi, favoriteApi } from '../services/api.js'

// ── State ──────────────────────────────────────────
const users          = ref([])
const selectedUserId = ref('')
const favorites      = ref([])
const loading        = ref(false)
const error          = ref('')
const showModal      = ref(false)
const editTarget     = ref(null)
const submitting     = ref(false)
const formError      = ref('')

const form = ref({ productName: '', price: '', feeRate: '', account: '', purchaseQuantity: '' })
const preview = ref({ totalFee: 0, totalAmount: 0 })

// ── Computed ───────────────────────────────────────
const currentUser = computed(() => users.value.find(u => u.userId === selectedUserId.value))
const sumFee      = computed(() => favorites.value.reduce((s, f) => s + Number(f.totalFee),    0))
const sumAmount   = computed(() => favorites.value.reduce((s, f) => s + Number(f.totalAmount), 0))

// ── Lifecycle ──────────────────────────────────────
onMounted(async () => {
  try {
    const res = await userApi.getAll()
    users.value = res.data
  } catch (e) {
    error.value = e.message
  }
})

// ── Methods ────────────────────────────────────────
async function loadFavorites() {
  if (!selectedUserId.value) { favorites.value = []; return }
  loading.value = true
  error.value   = ''
  try {
    const res = await favoriteApi.getList(selectedUserId.value)
    favorites.value = res.data
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

function calcPreview() {
  const p = Number(form.value.price) || 0
  const r = Number(form.value.feeRate) || 0
  const q = Number(form.value.purchaseQuantity) || 0
  const fee    = Math.round(p * q * r * 100) / 100
  const amount = Math.round((p * q + fee) * 100) / 100
  preview.value = { totalFee: fee, totalAmount: amount }
}

function openAdd() {
  editTarget.value = null
  form.value       = { productName: '', price: '', feeRate: '', account: currentUser.value?.account || '', purchaseQuantity: '' }
  preview.value    = { totalFee: 0, totalAmount: 0 }
  formError.value  = ''
  showModal.value  = true
}

function openEdit(f) {
  editTarget.value = f
  form.value = {
    productName:      f.productName,
    price:            f.price,
    feeRate:          f.feeRate,
    account:          f.account,
    purchaseQuantity: f.purchaseQuantity
  }
  calcPreview()
  formError.value = ''
  showModal.value = true
}

async function submitForm() {
  submitting.value = true
  formError.value  = ''
  try {
    if (editTarget.value) {
      // 更改
      await favoriteApi.update(editTarget.value.sn, selectedUserId.value, {
        productName:      form.value.productName,
        price:            Number(form.value.price),
        feeRate:          Number(form.value.feeRate),
        account:          form.value.account,
        purchaseQuantity: Number(form.value.purchaseQuantity)
      })
    } else {
      // 新增
      await favoriteApi.add({
        userId:           selectedUserId.value,
        productName:      form.value.productName,
        price:            Number(form.value.price),
        feeRate:          Number(form.value.feeRate),
        account:          form.value.account,
        purchaseQuantity: Number(form.value.purchaseQuantity)
      })
    }
    showModal.value = false
    await loadFavorites()
  } catch (e) {
    formError.value = e.message
  } finally {
    submitting.value = false
  }
}

async function confirmDelete(f) {
  if (!confirm(`確定刪除「${f.productName}」？\n此操作將同時刪除商品資料，無法復原。`)) return
  try {
    await favoriteApi.delete(f.sn)
    await loadFavorites()
  } catch (e) {
    alert(e.message)
  }
}

// ── Formatters ─────────────────────────────────────
function formatMoney(v) {
  return Number(v).toLocaleString('zh-TW', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}
function formatRate(v) {
  return (Number(v) * 100).toFixed(2) + '%'
}
</script>

<style scoped>
.user-card {
  display: flex;
  align-items: center;
  gap: 16px;
  flex-wrap: wrap;
  margin-bottom: 20px;
  padding: 14px 20px;
}
.user-card label { font-weight: 600; white-space: nowrap; }
.user-card select {
  padding: 6px 12px;
  border: 1px solid #ccc;
  border-radius: 6px;
  font-size: .95rem;
  min-width: 220px;
}
.user-info { color: #1a6cb5; font-size: .9rem; }

.card {
  background: #fff;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0,0,0,.08);
  padding: 20px 24px;
  margin-bottom: 20px;
}
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
}
h2 { font-size: 1.2rem; color: #0a3d7a; }

.table { width: 100%; border-collapse: collapse; font-size: .88rem; }
.table th {
  background: #0a3d7a;
  color: #fff;
  padding: 10px 12px;
  text-align: left;
  white-space: nowrap;
}
.table td { padding: 10px 12px; border-bottom: 1px solid #eef0f4; }
.table tbody tr:hover td { background: #f5f8ff; }
.table .num   { text-align: right; font-variant-numeric: tabular-nums; }
.table .fee   { color: #c0392b; }
.table .amount { color: #0a3d7a; font-weight: 600; }
.table .email { font-size: .8rem; color: #666; }
.table .empty { text-align: center; color: #999; padding: 32px; }
tfoot td { background: #f0f4ff; font-size: .9rem; }
.total-label { text-align: right; font-weight: 600; }

.btn { padding: 8px 18px; border: none; border-radius: 6px; cursor: pointer; font-size: .88rem; transition: opacity .2s; }
.btn:hover:not(:disabled) { opacity: .85; }
.btn:disabled { opacity: .5; cursor: not-allowed; }
.btn-primary   { background: #0a3d7a; color: #fff; }
.btn-secondary { background: #6c757d; color: #fff; }
.btn-sm { padding: 4px 10px; font-size: .8rem; margin-right: 4px; }
.btn-edit   { background: #1a6cb5; color: #fff; }
.btn-delete { background: #dc3545; color: #fff; }

.loading { text-align: center; padding: 40px; color: #888; }
.alert { padding: 10px 14px; border-radius: 6px; margin-bottom: 12px; font-size: .9rem; }
.alert-error { background: #fff0f0; color: #c0392b; border: 1px solid #f5c6cb; }

.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,.45);
  display: flex; align-items: center; justify-content: center;
  z-index: 100;
}
.modal {
  background: #fff;
  border-radius: 12px;
  padding: 28px 32px;
  width: 480px;
  max-width: 95vw;
  box-shadow: 0 8px 32px rgba(0,0,0,.2);
}
.modal h3 { margin-bottom: 20px; color: #0a3d7a; font-size: 1.1rem; }
.form-row { margin-bottom: 14px; }
.two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
.form-group { display: flex; flex-direction: column; gap: 5px; }
.form-group label { font-size: .85rem; font-weight: 600; color: #444; }
.form-group small { font-weight: 400; color: #888; }
.form-group input {
  padding: 8px 12px;
  border: 1px solid #ccc;
  border-radius: 6px;
  font-size: .9rem;
}
.form-group input:focus { outline: none; border-color: #1a6cb5; box-shadow: 0 0 0 2px rgba(26,108,181,.15); }

.preview {
  display: flex;
  gap: 16px;
  background: #f0f5ff;
  border-radius: 8px;
  padding: 12px 16px;
  margin-bottom: 14px;
}
.preview-item { display: flex; flex-direction: column; gap: 2px; flex: 1; }
.preview-item span  { font-size: .78rem; color: #666; }
.preview-item .fee    { color: #c0392b; font-size: 1.05rem; }
.preview-item .amount { color: #0a3d7a; font-size: 1.05rem; }

.modal-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; }
</style>
