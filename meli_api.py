import requests
import csv
import time

# Função para se obter o resultado da busca
def get_search_results(query, limit=50):
    url = f'https://api.mercadolibre.com/sites/MLA/search?q={query}&limit={limit}'
    response = requests.get(url)
    if response.status_code == 200:
        return response.json().get('results', [])
    else:
        return []

# Função para obter detalhes de um ítem usando o Item_Id
def get_item_details(item_id):
    url = f'https://api.mercadolibre.com/items/{item_id}'
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        return {}

# Função para escrever o resultado em um arquivo CSV
def write_to_csv(data, filename='mercadolibre_results.csv'):
    keys = data[0].keys()  # Busca a primera linha como referência para para as chaves
    with open(filename, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=keys)
        writer.writeheader()
        writer.writerows(data)

def main():
    search_terms = ["googlehome", "appletv", "amazonfiretv"]
    all_items = []

    for term in search_terms:
        print(f"Obtendo resultados para: {term}")
        search_results = get_search_results(term)

        for item in search_results:
            item_id = item['id']
            print(f"Obtendo detalhes do item: {item_id}")
            item_details = get_item_details(item_id)

            # Desnormalizar JSON e adicionar a lista
            if item_details:
                item_data = {
                    'id': item_details.get('id'),
                    'title': item_details.get('title'),
                    'price': item_details.get('price'),
                    'currency_id': item_details.get('currency_id'),
                    'condition': item_details.get('condition'),
                    'available_quantity': item_details.get('available_quantity'),
                    'sold_quantity': item_details.get('sold_quantity'),
                    'permalink': item_details.get('permalink'),
                    'category_id': item_details.get('category_id'),
                    'brand': item_details.get('attributes', [{}])[0].get('value_name', 'N/A'),
                    'shipping_free': item_details.get('shipping', {}).get('free_shipping', False)
                }

                all_items.append(item_data)

            # Evitar fazer muitas solicitações para a API em pouco tempo (limite de solicitações)
            time.sleep(1)

    # Escrever os resultados em um arquivo CSV
    if all_items:
        write_to_csv(all_items)
        print(f"Resultados armazenados em mercadolibre_results.csv")
    else:
        print("Não houve resultados.")

# Checando se o script está sendo executado diretamente
if __name__ == '__main__':
    main()
