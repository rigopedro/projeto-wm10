const router = {
    routes: {
        '/login': { path: 'views/login.html', init: null },
        '/register': { path: 'views/register.html', init: null },
        '/products': { path: 'views/products-list.html', init: () => products.initList() },
        '/products/new': { path: 'views/product-form.html', init: () => products.initForm() },
        '/products/edit/:id': { path: 'views/product-form.html', init: (id) => products.initForm(id) }
    },

    init: function () {
        $(window).on('hashchange', this.loadRoute.bind(this));
        this.loadRoute();
    },

    loadRoute: function () {
        const hash = window.location.hash || '#/login';
        let path = hash.split('?')[0].replace('#', '');

        const token = localStorage.getItem('authToken');
        if (!token && path !== '/login' && path !== '/register') {
            window.location.hash = '#/login';
            return;
        }
        if (token && (path === '/login' || path === '/register')) {
            window.location.hash = '#/products';
            return;
        }

        let route = null;
        let routeId = null;

        for (const r in this.routes) {
            const routeRegex = new RegExp('^' + r.replace(/:\w+/g, '(\\d+)') + '$');
            const match = path.match(routeRegex);
            if (match) {
                route = this.routes[r];
                if (match[1]) {
                    routeId = match[1];
                }
                break;
            }
        }

        if (route) {
            $('#main-content').load(route.path, function () {
                if (route.init) {
                    route.init(routeId);
                }
            });
        } else {
            $('#main-content').html('<h1>404 - Rota não encontrada</h1>');
        }
    }
};