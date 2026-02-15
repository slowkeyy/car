<!DOCTYPE html>
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>住戶車號管理系統</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js" type="module"></script>
    <script src="https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js" type="module"></script>
    <script src="https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js" type="module"></script>
    <style>
        .glass-morphism {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        .tab-active {
            border-bottom: 3px solid #3b82f6;
            color: #3b82f6;
        }
    </style>
</head>
<body class="bg-slate-50 min-h-screen font-sans text-slate-900">

<div id="app" class="max-w-4xl mx-auto px-4 py-8">
    <!-- Header -->
    <header class="mb-8 text-center">
        <h1 class="text-3xl font-bold text-slate-800">住戶車號管理與測驗系統</h1>
        <p class="text-slate-500 mt-2">查詢、存檔與隨機考驗</p>
    </header>

    <!-- Tabs Navigation -->
    <nav class="flex justify-center space-x-8 mb-8 border-b border-slate-200">
        <button onclick="switchTab('search')" id="tab-search" class="pb-2 px-4 font-medium transition-all tab-active">車號查詢</button>
        <button onclick="switchTab('quiz')" id="tab-quiz" class="pb-2 px-4 font-medium transition-all text-slate-500 hover:text-blue-500">隨機測驗</button>
        <button onclick="switchTab('data')" id="tab-data" class="pb-2 px-4 font-medium transition-all text-slate-500 hover:text-blue-500">資料導入</button>
    </nav>

    <!-- Section: Search -->
    <section id="section-search" class="space-y-6">
        <div class="glass-morphism p-6 rounded-2xl shadow-sm">
            <div class="relative">
                <input type="text" id="search-input" placeholder="輸入車號或車位 (例如: CAN-8789 或 26A)..." 
                    class="w-full pl-12 pr-4 py-4 rounded-xl border border-slate-200 focus:ring-2 focus:ring-blue-500 focus:outline-none transition-all text-lg shadow-inner">
                <div class="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </div>
            </div>
        </div>

        <div id="result-container" class="hidden">
            <div class="bg-white p-8 rounded-2xl shadow-lg border border-slate-100 animate-in fade-in slide-in-from-bottom-4 duration-300">
                <div class="flex flex-col md:flex-row gap-8">
                    <div class="flex-1 space-y-4">
                        <div class="flex items-center justify-between">
                            <h2 id="res-plate" class="text-4xl font-black text-blue-600 tracking-tight"></h2>
                            <span id="res-level" class="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm font-bold uppercase"></span>
                        </div>
                        <div class="grid grid-cols-2 gap-4 mt-4">
                            <div class="p-4 bg-slate-50 rounded-xl">
                                <p class="text-xs text-slate-400 uppercase font-bold">廠牌</p>
                                <p id="res-brand" class="text-xl font-semibold text-slate-700"></p>
                            </div>
                            <div class="p-4 bg-slate-50 rounded-xl">
                                <p class="text-xs text-slate-400 uppercase font-bold">顏色</p>
                                <p id="res-color" class="text-xl font-semibold text-slate-700"></p>
                            </div>
                            <div class="p-4 bg-slate-50 rounded-xl">
                                <p class="text-xs text-slate-400 uppercase font-bold">車位</p>
                                <p id="res-spot" class="text-xl font-semibold text-slate-700"></p>
                            </div>
                            <div class="p-4 bg-slate-50 rounded-xl">
                                <p class="text-xs text-slate-400 uppercase font-bold">序號</p>
                                <p id="res-id" class="text-xl font-semibold text-slate-700"></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="w-full md:w-64 space-y-4">
                        <div id="photo-display" class="w-full aspect-square bg-slate-100 rounded-xl flex flex-col items-center justify-center border-2 border-dashed border-slate-200 overflow-hidden relative group">
                            <span class="text-slate-400 text-sm">尚未上傳照片</span>
                            <img id="car-img" class="absolute inset-0 w-full h-full object-cover hidden">
                        </div>
                        <label class="block w-full text-center py-2 bg-slate-800 text-white rounded-lg cursor-pointer hover:bg-slate-700 transition-colors">
                            上傳/更新照片
                            <input type="file" id="photo-upload" accept="image/*" class="hidden" onchange="handleImageUpload(event)">
                        </label>
                    </div>
                </div>
            </div>
        </div>
        
        <div id="no-result" class="hidden text-center py-12 text-slate-400 italic">
            找不到資訊。
        </div>
    </section>

    <!-- Section: Quiz -->
    <section id="section-quiz" class="hidden space-y-6">
        <div class="bg-white p-8 rounded-2xl shadow-lg border border-slate-100 text-center">
            <h3 class="text-xl font-bold text-slate-600 mb-2">隨機測驗</h3>
            <p id="quiz-question-text" class="text-slate-400 mb-6">看車號，猜車位！</p>
            
            <div id="quiz-question" class="mb-8">
                <span id="quiz-plate" class="text-5xl font-black text-blue-600">----</span>
            </div>

            <div id="quiz-options" class="grid grid-cols-1 md:grid-cols-2 gap-4"></div>
            <div id="quiz-feedback" class="mt-6 h-8 font-bold"></div>
            <button onclick="generateQuiz()" class="mt-8 px-6 py-2 bg-blue-600 text-white rounded-full hover:bg-blue-700 shadow-md">下一題</button>
        </div>
    </section>

    <!-- Section: Data Import -->
    <section id="section-data" class="hidden space-y-6">
        <div class="bg-white p-8 rounded-2xl shadow-lg border border-slate-100">
            <h3 class="text-xl font-bold mb-4">資料導入工具</h3>
            <p class="text-sm text-slate-500 mb-4">請打開您的原始 HTML 檔案，複製全部內容並貼在下面：</p>
            <textarea id="raw-html-input" rows="10" class="w-full p-4 border border-slate-200 rounded-xl font-mono text-xs mb-4" placeholder="<html>...</html>"></textarea>
            <button onclick="importDataFromHTML()" class="w-full py-4 bg-emerald-600 text-white rounded-xl font-bold hover:bg-emerald-700 shadow-md transition-all">
                開始解析並導入雲端
            </button>
            <div id="import-status" class="mt-4 text-center text-sm font-medium"></div>
        </div>
    </section>

    <!-- Modals -->
    <div id="msg-modal" class="fixed inset-0 bg-black/50 hidden flex items-center justify-center z-50">
        <div class="bg-white p-6 rounded-xl max-w-sm w-full shadow-2xl">
            <p id="msg-content" class="text-center text-slate-700 font-medium"></p>
            <button onclick="closeModal()" class="mt-6 w-full py-2 bg-blue-600 text-white rounded-lg">確定</button>
        </div>
    </div>
</div>

<script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-app.js";
    import { getAuth, signInAnonymously, onAuthStateChanged, signInWithCustomToken } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-auth.js";
    import { getFirestore, doc, setDoc, getDoc, collection, onSnapshot, getDocs } from "https://www.gstatic.com/firebasejs/11.6.1/firebase-firestore.js";

    const firebaseConfig = JSON.parse(__firebase_config);
    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
    const db = getFirestore(app);
    const appId = typeof __app_id !== 'undefined' ? __app_id : 'car-management-app';

    let user = null;
    let carData = [];

    const initAuth = async () => {
        if (typeof __initial_auth_token !== 'undefined' && __initial_auth_token) {
            await signInWithCustomToken(auth, __initial_auth_token);
        } else {
            await signInAnonymously(auth);
        }
    };
    initAuth();

    onAuthStateChanged(auth, (u) => {
        user = u;
        if (user) syncData();
    });

    function syncData() {
        const q = collection(db, 'artifacts', appId, 'public', 'data', 'cars');
        onSnapshot(q, (snapshot) => {
            carData = snapshot.docs.map(doc => doc.data());
        });
    }

    window.switchTab = (tab) => {
        ['search', 'quiz', 'data'].forEach(s => {
            document.getElementById(`section-${s}`).classList.add('hidden');
            document.getElementById(`tab-${s}`).classList.remove('tab-active');
        });
        document.getElementById(`section-${tab}`).classList.remove('hidden');
        document.getElementById(`tab-${tab}`).classList.add('tab-active');
        if(tab === 'quiz') generateQuiz();
    };

    // --- 解析邏輯 ---
    window.importDataFromHTML = async () => {
        const input = document.getElementById('raw-html-input').value;
        const status = document.getElementById('import-status');
        if(!input) return showMessage("請貼入 HTML 代碼");

        status.innerText = "正在分析並上傳...";
        try {
            const parser = new DOMParser();
            const docObj = parser.parseFromString(input, 'text/html');
            const rows = docObj.querySelectorAll('tr');
            let count = 0;

            for (const row of rows) {
                const cells = row.querySelectorAll('td');
                // 根據你提供的檔案結構：td[0]=ID, td[1]=Plate(含A標籤), td[2]=Brand, td[3]=Color, td[4]=Level, td[5]=Spot
                if (cells.length >= 6) {
                    const plate = cells[1].innerText.trim();
                    if (!plate || plate === "車號") continue;

                    const carInfo = {
                        id: cells[0].innerText.trim(),
                        plate: plate,
                        brand: cells[2].innerText.trim(),
                        color: cells[3].innerText.trim(),
                        level: cells[4].innerText.trim(),
                        spot: cells[5].innerText.trim(),
                        updatedAt: Date.now()
                    };

                    const carDoc = doc(db, 'artifacts', appId, 'public', 'data', 'cars', carInfo.plate);
                    await setDoc(carDoc, carInfo, { merge: true });
                    count++;
                }
            }
            status.innerText = `成功導入 ${count} 筆車籍資料！`;
            status.className = "mt-4 text-center text-sm font-medium text-emerald-600";
        } catch (err) {
            status.innerText = "導入出錯：" + err.message;
            status.className = "mt-4 text-center text-sm font-medium text-red-600";
        }
    };

    // --- 搜尋與顯示 ---
    document.getElementById('search-input').addEventListener('input', (e) => {
        const val = e.target.value.toUpperCase().trim();
        if (!val) {
            document.getElementById('result-container').classList.add('hidden');
            return;
        }
        const found = carData.find(c => c.plate.toUpperCase().includes(val) || c.spot.toUpperCase().includes(val));
        if (found) {
            displayCar(found);
            document.getElementById('result-container').classList.remove('hidden');
            document.getElementById('no-result').classList.add('hidden');
        } else {
            document.getElementById('result-container').classList.add('hidden');
            document.getElementById('no-result').classList.remove('hidden');
        }
    });

    function displayCar(car) {
        document.getElementById('res-plate').innerText = car.plate;
        document.getElementById('res-brand').innerText = car.brand;
        document.getElementById('res-color').innerText = car.color;
        document.getElementById('res-spot').innerText = car.spot;
        document.getElementById('res-level').innerText = car.level;
        document.getElementById('res-id').innerText = car.id;
        const img = document.getElementById('car-img');
        const placeholder = document.querySelector('#photo-display span');
        if (car.photoBase64) {
            img.src = car.photoBase64;
            img.classList.remove('hidden');
            placeholder.classList.add('hidden');
        } else {
            img.classList.add('hidden');
            placeholder.classList.remove('hidden');
        }
    }

    window.handleImageUpload = async (event) => {
        const file = event.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = async (e) => {
            const base64 = e.target.result;
            const currentPlate = document.getElementById('res-plate').innerText;
            try {
                const carDoc = doc(db, 'artifacts', appId, 'public', 'data', 'cars', currentPlate);
                await setDoc(carDoc, { photoBase64: base64 }, { merge: true });
                showMessage("照片上傳成功！");
                document.getElementById('car-img').src = base64;
                document.getElementById('car-img').classList.remove('hidden');
                document.querySelector('#photo-display span').classList.add('hidden');
            } catch (err) { showMessage("儲存失敗"); }
        };
        reader.readAsDataURL(file);
    };

    // --- 測驗 ---
    let correctSpot = "";
    window.generateQuiz = () => {
        if (carData.length < 4) return;
        const correct = carData[Math.floor(Math.random() * carData.length)];
        correctSpot = correct.spot;
        document.getElementById('quiz-plate').innerText = correct.plate;
        document.getElementById('quiz-feedback').innerText = "";
        
        let options = [correct.spot];
        while (options.length < 4) {
            const r = carData[Math.floor(Math.random() * carData.length)].spot;
            if(!options.includes(r)) options.push(r);
        }
        options.sort(() => Math.random() - 0.5);
        const container = document.getElementById('quiz-options');
        container.innerHTML = "";
        options.forEach(opt => {
            const b = document.createElement('button');
            b.className = "p-4 bg-slate-50 border rounded-xl font-bold hover:bg-blue-50";
            b.innerText = opt;
            b.onclick = () => {
                const fb = document.getElementById('quiz-feedback');
                if(opt === correctSpot) {
                    fb.innerText = "正確！ 🎉"; fb.className="mt-6 font-bold text-emerald-500";
                } else {
                    fb.innerText = "錯了，答案是 " + correctSpot; fb.className="mt-6 font-bold text-red-500";
                }
                document.querySelectorAll('#quiz-options button').forEach(btn => btn.disabled = true);
            };
            container.appendChild(b);
        });
    };

    window.closeModal = () => document.getElementById('msg-modal').classList.add('hidden');
    function showMessage(t) { document.getElementById('msg-content').innerText = t; document.getElementById('msg-modal').classList.remove('hidden'); }
</script>
</body>
</html>
