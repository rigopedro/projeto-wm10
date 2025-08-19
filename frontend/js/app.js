const app = {
    init: function () {
        this.updateNav();
        this.bindEvents();
    },

    updateNav: function () {
        const token = localStorage.getItem('authToken');
        const userName = localStorage.getItem('userName');

        if (token) {
            $('#nav-username').show();
            $('#username-display').text(userName);
            $('#nav-logout').show();
        } else {
            $('#nav-username').hide();
            $('#nav-logout').hide();
        }
    },

    bindEvents: function () {
        $(document).on('submit', '#login-form', auth.handleLogin.bind(auth));
        $(document).on('submit', '#register-form', auth.handleRegister.bind(auth));

        $('#logout-link').on('click', auth.logout);
    }
};

$(document).ready(function () {
    app.init();
});