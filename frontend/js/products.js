const products = {
    apiUrl: '../backend/api/products.asp',

    initList: function () {
        this.fetchProducts();
        $('#search-button').on('click', () => this.fetchProducts());
        $('#search-input').on('keypress', (e) => {
            if (e.which === 13) this.fetchProducts();
        });
        $(document).on('click', '.delete-btn', function () {
            const id = $(this).data('id');
            products.handleDelete(id);
        });
    },

    initForm: function (id) {
        if (id) {
            $('#form-title').text('Editar Produto');
            this.fetchProductById(id);
        } else {
            $('#form-title').text('Adicionar Novo Produto');
        }
        $('#product-form').on('submit', this.handleSave.bind(this));
    },

    fetchProducts: function () {
        const searchTerm = $('#search-input').val();
        const token = localStorage.getItem('authToken');
        $.ajax({
            url: this.apiUrl,
            type: 'GET',
            data: { search: searchTerm },
            headers: { 'Authorization': 'Bearer ' + token },
            success: (list) => this.renderTable(list),
            error: (xhr) => {
                $('#products-table-body').html('<tr><td colspan="6" class="text-center text-danger">Erro ao carregar produtos.</td></tr>');
                console.error(xhr);
            }
        });
    },

    fetchProductById: function (id) {
        const token = localStorage.getItem('authToken');
        $.ajax({
            url: `${this.apiUrl}?id=${id}`,
            type: 'GET',
            headers: { 'Authorization': 'Bearer ' + token },
            success: function (product) {
                $('#product-id').val(product.id);
                $('#product-name').val(product.name);
                $('#product-description').val(product.description);
                $('#product-price').val(product.price);
                $('#product-stock').val(product.stock);
            },
            error: (xhr) => alert('Erro ao buscar detalhes do produto.')
        });
    },

    renderTable: function (list) {
        const tableBody = $('#products-table-body');
        tableBody.empty();
        if (list && list.length > 0) {
            list.forEach(p => {
                const row = `
                    <tr>
                        <td>${p.id}</td>
                        <td>${p.name}</td>
                        <td>${p.description || ''}</td>
                        <td>R$ ${parseFloat(p.price).toFixed(2)}</td>
                        <td>${p.stock}</td>
                        <td>
                            <a href="#/products/edit/${p.id}" class="btn btn-sm btn-warning">Editar</a>
                            <button class="btn btn-sm btn-danger ms-1 delete-btn" data-id="${p.id}">Deletar</button>
                        </td>
                    </tr>`;
                tableBody.append(row);
            });
        } else {
            tableBody.html('<tr><td colspan="6" class="text-center">Nenhum produto encontrado.</td></tr>');
        }
    },

    handleSave: function (event) {
        event.preventDefault();
        const productId = $('#product-id').val();

        const productData = {
            name: $('#product-name').val(),
            description: $('#product-description').val(),
            price: $('#product-price').val(),
            stock: $('#product-stock').val()
        };

        const isEditing = !!productId;
        const ajaxType = isEditing ? 'PUT' : 'POST';
        const ajaxUrl = isEditing ? `${this.apiUrl}?id=${productId}` : this.apiUrl;
        const token = localStorage.getItem('authToken');

        $.ajax({
            url: ajaxUrl,
            type: ajaxType,
            contentType: 'application/json',
            data: JSON.stringify(productData),
            headers: { 'Authorization': 'Bearer ' + token },
            success: function (response) {
                alert(response.message);
                window.location.hash = '#/products';
            },
            error: (xhr) => alert('Erro ao salvar o produto.')
        });
    },

    handleDelete: function (id) {
        if (confirm(`Tem certeza que deseja deletar o produto com ID ${id}?`)) {
            const token = localStorage.getItem('authToken');
            $.ajax({
                url: `${this.apiUrl}?id=${id}`,
                type: 'DELETE',
                headers: { 'Authorization': 'Bearer ' + token },
                success: (response) => {
                    alert(response.message);
                    this.fetchProducts();
                },
                error: (xhr) => alert('Erro ao deletar o produto.')
            });
        }
    }
};