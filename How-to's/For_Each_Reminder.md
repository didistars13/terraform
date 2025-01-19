# Terraform: Using `for_each` with Lists, Sets, and Maps

This guide explains how to effectively use the `for_each` construct in Terraform, how it works with `list`, `set`, and `map`, and when to use each. It also provides practical examples to demonstrate their differences and applications.

---

## 1. **Understanding `list`, `set`, and `map` in Terraform**

### **List**
- A `list` is an **ordered collection** of values.
- Each value is identified by an **index**.
- **Duplicates** are allowed.

#### Example:
```hcl
variable "my_list" {
  default = ["dev", "stage", "prod"]
}
```

**Accessing Items:**
```hcl
# Access the first item
var.my_list[0] # "dev"
```

### **Set**
- A `set` is an **unordered collection** of unique values.
- **Duplicates** are not allowed.
- Ordering is not guaranteed.

#### Example:
```hcl
variable "my_set" {
  default = toset(["dev", "stage", "prod", "dev"]) # "dev" is deduplicated
}
```

### **Map**
- A `map` is a collection of **key-value pairs**, where each key is unique.
- Values are accessed using the **key**.

#### Example:
```hcl
variable "my_map" {
  default = {
    dev   = "development"
    stage = "staging"
    prod  = "production"
  }
}
```

**Accessing Items:**
```hcl
var.my_map["dev"] # "development"
```

---

## 2. **Using `for_each`**

The `for_each` construct allows Terraform to iterate over a collection (`set` or `map`) to create multiple instances of resources or modules. It doesn’t directly accept a `list`.

### **Why `toset`?**
- If your input is a `list`, you must use `toset()` to convert it into a `set` because `for_each` requires a **set** or a **map**.
- A `set` ensures that all values are unique and can act as keys for `for_each`.

### **Example:**

#### Using a `Set`:
```hcl
locals {
  environments = ["dev", "stage", "prod"]
}

module "workloads" {
  for_each = toset(local.environments)
  source   = "module_source"
  env      = each.key
}
```

- `toset(local.environments)` converts the list `"[dev, stage, prod]"` into a set.
- Terraform creates one module instance for each item:
  - `module.workloads["dev"]`
  - `module.workloads["stage"]`
  - `module.workloads["prod"]`.

---

### **Using a Map:**
```hcl
locals {
  environments = {
    dev   = "us-east-1"
    stage = "us-west-1"
    prod  = "eu-central-1"
  }
}

module "workloads" {
  for_each = local.environments
  source   = "module_source"
  env      = each.key
  region   = each.value
}
```

- `for_each = local.environments` iterates over the map.
- `each.key` is the environment name (e.g., `dev`).
- `each.value` is the corresponding region (e.g., `us-east-1`).

Terraform creates:
- `module.workloads["dev"]` with `region = "us-east-1"`
- `module.workloads["stage"]` with `region = "us-west-1"`
- `module.workloads["prod"]` with `region = "eu-central-1"`.

---

## 3. **Key Differences Between List, Set, and Map**

| Feature                 | List           | Set            | Map                          |
|-------------------------|----------------|----------------|------------------------------|
| Ordered                | Yes            | No             | No                           |
| Allows Duplicates       | Yes            | No             | No (keys are unique)         |
| Access by Index         | Yes            | No             | No                           |
| Access by Key           | No             | No             | Yes                          |
| Use Case               | Preserve order | Ensure uniqueness | Store key-value pairs     |

---

## 4. **Best Practices with `for_each`**

- Use `toset()` to convert lists to sets when using `for_each`.
- Use maps when you need to associate metadata or additional values with each key.
- Avoid unnecessary conversions if your data is already in the required format.

### **Example of Combining Map and Set:**
If you have a list of environments but need to add metadata dynamically:
```hcl
locals {
  environments = ["dev", "stage", "prod"]
  environment_metadata = {
    dev   = "development"
    stage = "staging"
    prod  = "production"
  }
}

module "workloads" {
  for_each = tomap({ for env in local.environments : env => local.environment_metadata[env] })
  source   = "module_source"
  env      = each.key
  desc     = each.value
}
```

This creates a map dynamically using `for`, where each environment is the key and its description is the value.

---

## 5. **Common Errors with `for_each`**

1. **Passing a List Directly:**
   ```hcl
   for_each = local.environments # Error: "Invalid for_each argument"
   ```
   Solution: Use `toset()` to convert the list to a set.

2. **Duplicate Keys in a Map:**
   ```hcl
   for_each = { "dev" = 1, "dev" = 2 } # Error: "Duplicate key"
   ```
   Solution: Ensure all keys in the map are unique.

---

## 6. **When to Use Each Type**

| Use Case                       | Best Choice      |
|--------------------------------|------------------|
| Preserving order               | **List**         |
| Ensuring unique values         | **Set**          |
| Storing key-value pairs        | **Map**          |
| Iterating with `for_each`      | **Set** or **Map** |

---

This guide should clarify how `for_each` interacts with lists, sets, and maps in Terraform. If you have further questions or need assistance, feel free to ask!

