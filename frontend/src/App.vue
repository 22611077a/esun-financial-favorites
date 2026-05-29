<template>
  <div id="app-root">
    <header>
      <nav>
        <img src="https://www.esunbank.com/favicon.ico" alt="E.SUN" class="logo" onerror="this.style.display='none'">
        <span class="brand">玉山銀行 E.SUN BANK</span>
        <router-link to="/favorites">金融商品喜好管理</router-link>
      </nav>
    </header>
    <main>
      <router-view />
    </main>
  </div>
</template>

<style>
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Microsoft JhengHei', 'Segoe UI', sans-serif; background: #f0f4f8; color: #333; }

header {
  background: linear-gradient(135deg, #0a3d7a 0%, #1a6cb5 100%);
  padding: 0 32px;
  height: 60px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 8px rgba(0,0,0,.25);
}
nav { display: flex; align-items: center; gap: 20px; }
.logo { height: 28px; }
.brand { color: #fff; font-size: 1.15rem; font-weight: 700; letter-spacing: .5px; }
nav a { color: #a8d0f0; text-decoration: none; font-size: .9rem; padding: 4px 12px; border-radius: 4px; transition: background .2s; }
nav a:hover, nav a.router-link-active { background: rgba(255,255,255,.2); color: #fff; }

main { max-width: 1100px; margin: 28px auto; padding: 0 20px; }
</style>
