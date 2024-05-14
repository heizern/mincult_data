# Загрузка необходимых библиотек
library(dplyr)
library(jsonlite)
library(purrr)

# Чтение файла CSV, проверка
data <- read.csv("path/file.csv",  row.names = NULL, sep=",")

print(names(data))

head(data)

# Задаем названия переменным
name = data$Объект
point = data$На.карте


# Обработка JSON и создание новых столбцов
data_transformed <- data %>%
  mutate(
    # Преобразование JSON строки в список, обработка ошибок
    point_parsed = map(point, safely(fromJSON)),
    # Извлечение широты и долготы, обработка случаев с ошибками парсинга
    latitude = map_dbl(point_parsed, ~ .x$result$coordinates[2] %||% NA),
    longitude = map_dbl(point_parsed, ~ .x$result$coordinates[1] %||% NA)
  ) %>%
  select(latitude, longitude) 

# Просмотр результатов
print(data_transformed)

# Добавим столбец для идентификации. Пускай это будет категория ОКН (федерального или регионального значения)

data_transformed <- data_transformed %>%
  dplyr::mutate(name = data$Id.Категория.историко.культурного.значения)

# Фильтрация данных для удаления строк с NA в координатах
data_clean <- data_transformed %>%
  filter(!is.na(latitude) & !is.na(longitude))

# Просмотр очищенных данных
print(data_clean)

# Зададим названия столбцов
colnames(data) <- c("lat", "long", "type")

# Проверка новых имен столбцов
print(colnames(data))


write.csv(data_clean, "path2/file2.csv", row.names = FALSE)
print ("ready")
