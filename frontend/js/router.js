const router = {
    routes: {
        '/login': { path: 'views/login.html', init: null },
        '/register': { path: 'views/register.html', init: null },
        '/products': { path: 'views/products-list.html', init: () => products.initList() }
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

        const route = this.routes[path];

        if (route) {
            $('#main-content').load(route.path, function () {
                if (route.init) {
                    route.init();
                }
            });
        } else {
            $('#main-content').html('<h1>404 - Rota não encontrada</h1>');
        }
    }
};