const auth = {
    apiUrl: '../backend/api/auth.asp',

    handleLogin: function (event) {
        event.preventDefault();

        const email = $('#email').val();
        const password = $('#password').val();

        $.ajax({
            url: `${this.apiUrl}?action=login`,
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ email: email, password: password }),
            success: function (response) {
                localStorage.setItem('authToken', response.token);
                localStorage.setItem('userName', response.userName);
                app.updateNav();
                window.location.hash = '#/products';
            },
            error: function (xhr) {
                const errorMessage = xhr.responseJSON ? xhr.responseJSON.message : 'Erro ao tentar fazer login.';
                alert(errorMessage);
            }
        });
    },

    handleRegister: function (event) {
        event.preventDefault();

        const name = $('#name').val();
        const email = $('#email').val();
        const password = $('#password').val();

        $.ajax({
            url: `${this.apiUrl}?action=register`,
            type: 'POST',
            contentType: 'application/json',
            data: JSON.stringify({ name: name, email: email, password: password }),
            success: function (response) {
                alert(response.message);
                window.location.hash = '#/login';
            },
            error: function (xhr) {
                const errorMessage = xhr.responseJSON ? xhr.responseJSON.message : 'Erro ao tentar registrar.';
                alert(errorMessage);
            }
        });
    },

    logout: function () {
        localStorage.removeItem('authToken');
        localStorage.removeItem('userName');
        app.updateNav();
        window.location.hash = '#/login';
    }
};