// import { create, router as _router, defaults } from 'json-server';
import auth from 'json-server-auth';
import cors from 'cors';

import jsonServer from 'json-server';
const { create, router: _router, defaults } = jsonServer;

const app = create();
const router = _router('user_data.json');
const middlewares = defaults();


app.db = router.db;

app.use(cors());
app.use(middlewares);

app.use(auth); // 👈 Add auth middleware before router
app.use(router);

app.listen(5000, () => {
  console.log('✅ JSON Server with Auth running on http://localhost:5000');
});
