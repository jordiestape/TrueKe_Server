 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `restful_api` CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `restful_api`;
-- -----------------------------------------------------
-- Table `restful_api`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restful_api`.`user`;

CREATE TABLE IF NOT EXISTS `restful_api`.`user` (

  `id` INT(70) AUTO_INCREMENT,
  `phone` VARCHAR(20) NOT NULL,
  `user` VARCHAR(20) NOT NULL,
  `password` VARCHAR(50) NOT NULL,
  `email` VARCHAR(50) NOT NULL,
  `birthDate` DATE NOT NULL,
  `products` INT(10) DEFAULT 0,
  `truekes` INT(10) DEFAULT 0,
  `imagePath` VARCHAR(140) DEFAULT '',
  `ratingsNumber` INT(10) DEFAULT 0,
  `ratingsValue` FLOAT(2, 1) DEFAULT 0.0,

  PRIMARY KEY (`id`),
  UNIQUE INDEX `phone_UNIQUE` (`phone` ASC),
  UNIQUE INDEX `email_UNIQUE` (`email` ASC)
) ENGINE = InnoDB;

-- Example of insert (user)
-- INSERT INTO `user`(`phone`, `user`, `password`, `email`, `birthDate`) VALUES ('654654654', 'Homer', 'passapalabra', 'homer@badulaque.com', '1996-04-02');

-- -----------------------------------------------------
-- Table `restful_api`.`user_payment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restful_api`.`payment_method`;

CREATE TABLE IF NOT EXISTS `restful_api`.`payment_method` (
  `id` INT(70) AUTO_INCREMENT,
  `user_id` INT(70) NOT NULL,
  `type` ENUM('Visa/4B/Euro6000', 'MasterCard/4B/Euro6000', 'American Express', 'Maestro'),
  `number` VARCHAR(20) NOT NULL,
  `expireDate` DATE NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `country` VARCHAR(50) NOT NULL,
  `province` VARCHAR(50) NOT NULL,
  `city` VARCHAR(50) NOT NULL,
  `postalCode` VARCHAR(50) NOT NULL,
  `address` VARCHAR(70) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,

  CONSTRAINT Pk_payment_method PRIMARY KEY (`id`),
  CONSTRAINT Uniques_payment_method UNIQUE KEY (`user_id`, `number`),
  CONSTRAINT Fk_user_id_payment_method FOREIGN KEY (`user_id`) REFERENCES user(`id`)
  ON DELETE CASCADE
) ENGINE = InnoDB;

-- Example of insert (payment_method)

-- INSERT INTO `user`(`phone`, `user`, `password`, `email`, `birthDate`) VALUES ('654654654', 'Homer', 'passapalabra', 'homer@badulaque.com', '1996-04-02');
-- INSERT INTO `payment_method`(`user_id`, `type`, `number`, `expireDate`, `name`, `country`, `province`, `city`, `postalCode`, `address`, `phone`) VALUES ('1', 'MasterCard/4B/Euro6000','1234123412341234', '2020-02-01', 'Homer', 'America', 'Barcelona', 'Springfield', '11101', 'Calle del general Comilla', '619703921');

-- -----------------------------------------------------
-- Table `restful_api`.`shipment_method`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restful_api`.`shipment_method`;

CREATE TABLE IF NOT EXISTS `restful_api`.`shipment_method` (

  `id` INT(70) AUTO_INCREMENT,
  `user_id` INT(70) NOT NULL,
  `country` VARCHAR(50) NOT NULL,
  `province` VARCHAR(50) NOT NULL,
  `city` VARCHAR(50) NOT NULL,
  `postalCode` VARCHAR(50) NOT NULL,
  `address` VARCHAR(70) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `idCard` VARCHAR(20) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,

  CONSTRAINT Pk_shipment_method PRIMARY KEY (`id`),
  CONSTRAINT Uniques_shipment_method UNIQUE KEY (`user_id`, `postalCode`, `address`),
  CONSTRAINT Fk_user_id_shipment_method FOREIGN KEY (`user_id`) REFERENCES user(`id`)
  ON DELETE CASCADE
) ENGINE = InnoDB;

-- Example of insert (payment_method)

-- INSERT INTO `user`(`phone`, `user`, `password`, `email`, `birthDate`) VALUES ('654654654', 'Homer', 'passapalabra', 'homer@badulaque.com', '1996-04-02');
-- INSERT INTO `shipment_method`(`user_id`, `country`, `province`, `city`, `postalCode`, `address`, `name`, `idCard`, `phone`) VALUES ('1', 'America', 'Barcelona', 'Springfield', '11101', 'Calle del general Comilla', 'Homer', '12931230', '619703921');

-- -----------------------------------------------------
-- Table `restful_api`.`category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restful_api`.`category`;

CREATE TABLE IF NOT EXISTS `restful_api`.`category` (

  `category` VARCHAR(50),

  CONSTRAINT Pk_category PRIMARY KEY (`category`)

) ENGINE = InnoDB;

-- Initial values
INSERT INTO `category`(`category`) VALUES ('vehículos');
INSERT INTO `category`(`category`) VALUES ('electrónico');
INSERT INTO `category`(`category`) VALUES ('deporte y ocio');
INSERT INTO `category`(`category`) VALUES ('hogar y electrodomésticos');
INSERT INTO `category`(`category`) VALUES ('consolas y videojuegos');
INSERT INTO `category`(`category`) VALUES ('libros, películas o música');
INSERT INTO `category`(`category`) VALUES ('moda y accesorios');
INSERT INTO `category`(`category`) VALUES ('otros');

-- Example of insert (category)
-- INSERT INTO `category`(`category`) VALUES ('electrodomestics');

-- -----------------------------------------------------
-- Table `restful_api`.`product`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restful_api`.`product`;

CREATE TABLE IF NOT EXISTS `restful_api`.`product` (

  `id` INT(70) AUTO_INCREMENT,
  `user_id` INT(70) NOT NULL,
  `title` VARCHAR(50) NOT NULL,
  `description` TEXT,
  `category` VARCHAR(50) NOT NULL,
  `min_price` INT(30) NOT NULL,
  `max_price` INT(30) NOT NULL,

  CONSTRAINT Pk_product PRIMARY KEY (`id`),
  CONSTRAINT Fk_user_id_product FOREIGN KEY (`user_id`) REFERENCES user(`id`) ON DELETE CASCADE,
  CONSTRAINT Fk_category_product FOREIGN KEY (`category`) REFERENCES category(`category`)

) ENGINE = InnoDB;

DELIMITER $$

-- CHECK (max_price >= min_price && min_price <= 0)
CREATE TRIGGER `product_check_price_range` BEFORE INSERT ON `product`
FOR EACH ROW
BEGIN
    IF new.`min_price` >= new.`max_price` OR new.`min_price` <= 0 THEN
        SIGNAL SQLSTATE '12345' SET message_text = 'Check constraint price range';
    END IF;

END$$

-- Increment number of products of an user if new product
CREATE TRIGGER `increments_user_produts` AFTER INSERT ON `product`
FOR EACH ROW
BEGIN

  UPDATE `restful_api`.`user` SET `products` = `products`+ 1 WHERE `id` = NEW.`user_id` LIMIT 1;

END$$

-- Decrement number of products of an user if delete product
CREATE TRIGGER `decrements_user_produts` AFTER DELETE ON `product`
FOR EACH ROW
BEGIN

  UPDATE `restful_api`.`user` SET `products` = `products`- 1 WHERE `id` = OLD.`user_id` LIMIT 1;

END$$

DELIMITER ;


-- Example of insert (product)

-- INSERT INTO `user`(`phone`, `user`, `password`, `email`, `birthDate`) VALUES ('654654654', 'Homer', 'passapalabra', 'homer@badulaque.com', '1996-04-02');
-- INSERT INTO `category`(`category`) VALUES ('electrodomestics');
-- INSERT INTO `product`( `user_id`, `title`, `description`, `category`, `min_price`, `max_price`) VALUES ('1', 'Clip Vermell', 'Et canviara la vida', 'electrodomestics', '1', '2');

-- Check Trigger Working
-- INSERT INTO `product`( `user_id`, `title`, `description`, `category`, `min_price`, `max_price`) VALUES ('1', 'Clip Vermell', 'Et canviara la vida', 'electrodomestics', '3', '2');
-- INSERT INTO `product`( `user_id`, `title`, `description`, `category`, `min_price`, `max_price`) VALUES ('1', 'Clip Vermell', 'Et canviara la vida', 'electrodomestics', '0', '2');

-- Increment if create product
-- INSERT INTO `user`(`phone`, `user`, `password`, `email`, `birthDate`) VALUES ('654654654', 'Homer', 'passapalabra', 'homer@badulaque.com', '1996-04-02');
-- INSERT INTO `user`(`phone`, `user`, `password`, `email`, `birthDate`) VALUES ('654654651', 'Homero', 'passapalabra', 'homer1@badulaque.com', '1996-04-02');
-- INSERT INTO `category`(`category`) VALUES ('electrodomestics');
-- INSERT INTO `product`( `user_id`, `title`, `description`, `category`, `min_price`, `max_price`) VALUES ('1', 'Clip Vermell', 'Et canviara la vida', 'electrodomestics', '1', '2');
-- DELETE FROM `product` WHERE `id` = 1;

-- -----------------------------------------------------
-- Table `restful_api`.`product_wants_category`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restful_api`.`product_wants_category`;

CREATE TABLE IF NOT EXISTS `restful_api`.`product_wants_category` (

  `product_id` INT (70),
  `category` VARCHAR(50),

  CONSTRAINT Pk_category PRIMARY KEY (`product_id`,`category`),
  CONSTRAINT Fk_category_product_wants_category FOREIGN KEY (`category`) REFERENCES category(`category`),
  CONSTRAINT Fk_product_product_wants_category_product FOREIGN KEY (`product_id`) REFERENCES product(`id`) ON DELETE CASCADE

) ENGINE = InnoDB;

-- Example of insert (product_wants_category)

-- INSERT INTO `user`(`phone`, `user`, `password`, `email`, `birthDate`) VALUES ('654654654', 'Homer', 'passapalabra', 'homer@badulaque.com', '1996-04-02');
-- INSERT INTO `category`(`category`) VALUES ('electrodomestics');
-- INSERT INTO `product`( `user_id`, `title`, `description`, `category`, `min_price`, `max_price`) VALUES ('1', 'Clip Vermell', 'Et canviara la vida', 'electrodomestics', '1', '2');
-- INSERT INTO `product_wants_category`(`product_id`,`category`) VALUES ('1','electrodomestics');


-- -----------------------------------------------------
-- Table `restful_api`.`chat`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restful_api`.`chat`;

CREATE TABLE IF NOT EXISTS `restful_api`.`chat` (

  `id` INT(70) AUTO_INCREMENT,
  `product_id1` INT (70),
  `product_id2` INT (70),

  CONSTRAINT Pk_chat PRIMARY KEY (`id`),
  CONSTRAINT Unique_chat UNIQUE (`product_id1`,`product_id2`),
  CONSTRAINT Fk_chat_product1 FOREIGN KEY (`product_id1`) REFERENCES product(`id`) ON DELETE CASCADE,
  CONSTRAINT Fk_chat_product2 FOREIGN KEY (`product_id2`) REFERENCES product(`id`) ON DELETE CASCADE

) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `restful_api`.`match`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restful_api`.`match`;

CREATE TABLE IF NOT EXISTS `restful_api`.`match` (

  `product_id1` INT (70),
  `product_id2` INT (70),
  `wants` INT (1),

  CONSTRAINT Pk_category PRIMARY KEY (`product_id1`,`product_id2`),
  CONSTRAINT Fk_match_product1 FOREIGN KEY (`product_id1`) REFERENCES product(`id`) ON DELETE CASCADE,
  CONSTRAINT Fk_match_product2 FOREIGN KEY (`product_id2`) REFERENCES product(`id`) ON DELETE CASCADE

) ENGINE = InnoDB;

DELIMITER $$

CREATE TRIGGER `match_check_not_same_product` BEFORE INSERT ON `match`
FOR EACH ROW
BEGIN
    IF new.`product_id1`= new.`product_id2` THEN
        SIGNAL SQLSTATE '12345' SET message_text = 'Check not same product match';
    END IF;

END$$

CREATE TRIGGER `open_new_chat` BEFORE INSERT ON `match`
FOR EACH ROW
BEGIN
    IF new.`wants`= 1 THEN

        IF EXISTS ( SELECT 1
                    FROM `match`
                    WHERE `match`.`product_id1` = NEW.product_id2 AND
                          `match`.`product_id2` = NEW.product_id1 AND
                          `match`.`wants`= 1) THEN

          INSERT INTO `chat`(`product_id1`, `product_id2`) VALUES (NEW.product_id1, NEW.product_id2);

        END IF;

    END IF;

END$$

DELIMITER ;
-- INSERT INTO `match`(`product_id1`, `product_id2`, `wants`) VALUES ('3', '4', 0);

-- -----------------------------------------------------
-- Table `restful_api`.`image`
-- -----------------------------------------------------
-- THIS TABLE NEEDS TO CREATE INSTANCES WITH THE REST API TO MANTAIN THE
-- CONSISTENCY INTO THE APP.
DROP TABLE IF EXISTS `restful_api`.`image`;

CREATE TABLE IF NOT EXISTS `restful_api`.`image` (

  `md5` CHAR(32),
  `imagePath` VARCHAR(250),

  PRIMARY KEY (`md5`)
) ENGINE = InnoDB;

-- THIS TABLE NEEDS TO CREATE INSTANCES WITH THE REST API TO MANTAIN THE
-- CONSISTENCY INTO THE APP.
DROP TABLE IF EXISTS `restful_api`.`product_has_images`;

CREATE TABLE IF NOT EXISTS `restful_api`.`product_has_images` (

  `image_md5` CHAR(32),
  `product_id` INT(70),

  CONSTRAINT Pk_category PRIMARY KEY (`image_md5`,`product_id`),
  CONSTRAINT Fk_product_has_images_image_md5 FOREIGN KEY (`image_md5`) REFERENCES image(`md5`) ON DELETE CASCADE,
  CONSTRAINT Fk_product_has_images_product_id FOREIGN KEY (`product_id`) REFERENCES product(`id`) ON DELETE CASCADE
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `restful_api`.`report`
-- -----------------------------------------------------
-- THIS TABLE NEEDS TO CREATE INSTANCES WITH THE REST API TO MANTAIN THE
-- CONSISTENCY INTO THE APP.
DROP TABLE IF EXISTS `restful_api`.`report`;

CREATE TABLE IF NOT EXISTS `restful_api`.`report` (

  `user_id` INT(70),
  `product_id` INT(70),

  CONSTRAINT Pk_category PRIMARY KEY (`user_id`,`product_id`),
  CONSTRAINT Fk_report_user_id FOREIGN KEY (`user_id`) REFERENCES user(`id`) ON DELETE CASCADE,
  CONSTRAINT Fk_report_product_id FOREIGN KEY (`product_id`) REFERENCES product(`id`) ON DELETE CASCADE
) ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `restful_api`.`trueke`

DROP TABLE IF EXISTS `restful_api`.`trueke`;

CREATE TABLE IF NOT EXISTS `restful_api`.`trueke` (

  `chat_id` INT(70),
  `paid`INT(2) DEFAULT 0,

  CONSTRAINT Pk_trueke PRIMARY KEY (`chat_id`),
  CONSTRAINT Fk_trueke_chat_id FOREIGN KEY (`chat_id`) REFERENCES chat(`id`) ON DELETE CASCADE

) ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
