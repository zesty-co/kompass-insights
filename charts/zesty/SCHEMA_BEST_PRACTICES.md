# Helm Schema Best Practices Guide

This document outlines best practices for defining JSON Schema annotations in Helm chart `values.yaml` files using the `helm-schema` tool.

## Table of Contents

- [Basic Schema Syntax](#basic-schema-syntax)
- [Type Definitions](#type-definitions)
- [Required Fields](#required-fields)
- [Additional Properties](#additional-properties)
- [Validation Constraints](#validation-constraints)
- [Format Specifications](#format-specifications)
- [Pattern Matching](#pattern-matching)
- [Enum Values](#enum-values)
- [Documentation Comments](#documentation-comments)
- [Common Patterns](#common-patterns)

---

## Basic Schema Syntax

### Annotation Structure

Schema annotations must be placed between `# @schema` markers, directly above the field they annotate:

```yaml
# @schema
# type: string
# required: true
# @schema
# Field description here
fieldName: value
```

**Key Rules:**
- Opening `# @schema` marker
- Schema properties (one per line, prefixed with `#`)
- Closing `# @schema` marker
- Optional documentation comment (after closing marker)
- Field definition

### Root-Level Schema

Use `@schema.root` to define schema properties for the entire values file:

```yaml
# @schema.root
# additionalProperties: true
# @schema.root
```

This must be placed at the very beginning of the file, before any field definitions.

---

## Type Definitions

### Basic Types

Always specify the `type` for each field:

```yaml
# @schema
# type: string
# @schema
name: "example"

# @schema
# type: integer
# @schema
count: 5

# @schema
# type: boolean
# @schema
enabled: true

# @schema
# type: object
# @schema
config: {}

# @schema
# type: array
# @schema
items: []
```

### When to Omit Type

**Only omit `type` when using `enum`** - the type is inferred from enum values:

```yaml
# @schema
# required: true
# enum: [Ignore, Fail]
# @schema
failurePolicy: Ignore
```

---

## Required Fields

### Understanding `required` in Helm Schema

**Important:** Helm merges user-provided values with default `values.yaml` before validating against the schema. This means:

- `required: true` validates the **final merged configuration**, not individual value files
- Users don't need to specify fields marked `required: true` if defaults provide them
- The validation ensures critical fields exist in the final result

### `required: true` - Mandatory in Final Configuration

Use `required: true` for fields that must exist in the final merged configuration:

```yaml
# @schema
# type: object
# required: true
# @schema
deployment:
  # @schema
  # type: string
  # required: true
  # @schema
  repository: "example.com/image"
```

**What this means:**
- The field **must exist** in the final merged values (default + user overrides)
- The field **cannot be null** when present
- Users can override the value but don't need to specify it if the default is acceptable
- Empty strings (`""`) are valid for string types

**Example behavior:**

User's custom values:
```yaml
deployment:
  image:
    pullPolicy: Always  # Only override pullPolicy
```

Merged result (validated):
```yaml
deployment:
  image:
    repository: "example.com/image"  # ✅ From defaults - validation passes
    pullPolicy: Always                # ✅ From user override
```

### `required: false` - Optional Fields

Use `required: false` for fields that can be completely omitted from the final configuration:

```yaml
# @schema
# type: object
# required: false
# @schema
pdb:  # Entire section is optional
  # @schema
  # type: integer
  # required: false
  # @schema
  maxUnavailable: 1
```

**What this means:**
- The field **can be omitted** entirely from the final configuration
- The field **can be null** when present
- Empty strings (`""`) are valid for string types
- Users can choose not to use this feature at all

**Common use cases:**

1. **Optional features** that users may not need:
   ```yaml
   # @schema
   # type: object
   # required: false
   # @schema
   pdb:  # Pod Disruption Budget is optional
   ```

2. **Deprecated fields** being phased out:
   ```yaml
   # @schema
   # type: object
   # required: false
   # @schema
   cxLogging:  # Being deprecated in favor of global.cxLogging
   ```

3. **Override fields** that users rarely need to customize:
   ```yaml
   # @schema
   # type: string
   # required: false
   # @schema
   nameOverride: ""  # Empty = use default chart name; users set only if customizing
   ```

   **Explanation:** Fields like `nameOverride` allow users to customize generated resource names. Most users don't need this, so `required: false` lets them omit it entirely. The empty string default means "use standard naming" - users only set a value when they actually want to override the default behavior.

### Nested Field Requirements

Nested fields inherit the optionality of their parent, but can have their own `required` settings:

```yaml
# @schema
# type: object
# required: false
# @schema
cxLogging:  # Parent is optional
  # @schema
  # type: string
  # required: false
  # @schema
  clusterName: ""  # Child is also optional, can be empty string
```

**Behavior:**
- If `cxLogging` is omitted entirely: ✅ Valid (parent is `required: false`)
- If `cxLogging` is provided but `clusterName` is omitted: ✅ Valid (child is `required: false`)
- If `cxLogging` is provided with `clusterName: ""`: ✅ Valid (empty string is valid for strings)

---

## Additional Properties

### When to Use `additionalProperties: true`

Use this for objects that should accept arbitrary key-value pairs beyond defined properties.

#### 1. Global Configuration Objects

For fields shared across multiple charts or components:

```yaml
# @schema
# type: object
# required: false
# additionalProperties: true
# @schema
global:
# Allows parent charts to add their own global configurations
```

**Use Case:** Parent Helm charts may inject additional global values that subcharts don't know about.

#### 2. Cross-Chart Communication

For fields passed between multiple subcharts:

```yaml
# @schema
# type: object
# required: false
# additionalProperties: true
# @schema
cxLogging:
# Allows different subcharts to add their own logging fields
```

**Use Case:** Multiple subcharts share the same logging configuration but may have different requirements.

#### 3. Kubernetes-Style Configuration Maps

For fields that accept arbitrary Kubernetes labels, annotations, selectors, or other user-defined configurations:

```yaml
# @schema
# type: object
# required: false
# additionalProperties: true
# @schema
nodeSelector: {}

# @schema
# type: object
# required: false
# additionalProperties: true
# @schema
annotations: {}

# @schema
# type: array
# required: false
# @schema
tolerations: []

# @schema
# type: array
# required: false
# @schema
extraEnv: []

# @schema
# type: object
# required: false
# @schema
securityContext:
  # @schema
  # type: object
  # required: false
  # @schema
  capabilities:
    # @schema
    # type: array
    # required: false
    # @schema
    drop:
      - ALL
  # @schema
  # type: object
  # required: false
  # @schema
  seccompProfile:
    # @schema
    # type: string
    # required: true
    # @schema
    type: RuntimeDefault

# @schema
# type: object
# required: false
# @schema
resources:
  # @schema
  # type: object
  # required: false
  # @schema
  limits:
    # @schema
    # type: string
    # required: false
    # pattern: ^[0-9]+(\.[0-9]+)?(Ki|Mi|Gi|Ti|Pi|Ei|k|M|G|T|P|E)?$
    # @schema
    memory: 2Gi
  # @schema
  # type: object
  # required: false
  # @schema
  requests:
    # @schema
    # type: string
    # required: false
    # pattern: ^[0-9]+(\.[0-9]+)?m?$
    # @schema
    cpu: 250m
    # @schema
    # type: string
    # required: false
    # pattern: ^[0-9]+(\.[0-9]+)?(Ki|Mi|Gi|Ti|Pi|Ei|k|M|G|T|P|E)?$
    # @schema
    memory: 2Gi
```

**Use Case:** These Kubernetes configuration fields are optional since most users don't need to customize them:
- **nodeSelector/annotations**: Accept arbitrary key-value pairs for Kubernetes labels and annotations
- **tolerations/extraEnv**: Accept arrays of user-defined configurations
- **securityContext**: Allows users to define pod/container security settings. Nested objects and arrays like `capabilities`, `capabilities.drop`, and `seccompProfile` are also optional - users can omit security restrictions if not needed
- **resources**: While best practice is to set resource limits/requests, users can omit them for development or when relying on namespace defaults. All nested fields are also optional - users can specify only limits, only requests, or specific resources within each

#### 4. Flexible Configuration Objects

For objects where the schema cannot predict all possible fields:

```yaml
# @schema
# type: object
# required: false
# additionalProperties: true
# @schema
pdb:
# Allows users to specify maxUnavailable, minAvailable, or other PDB fields
```

**Use Case:** Pod Disruption Budget can have `maxUnavailable` OR `minAvailable`, plus other optional fields.

**PersistentVolumeClaim Specifications:**

```yaml
# @schema
# type: object
# required: true
# additionalProperties: true
# @schema
spec:
  # Define common fields like accessModes, resources
  # But allow additional fields like storageClassName, selector, volumeMode, etc.
```

**Use Case:** PVC specs have many optional Kubernetes fields (storageClassName, selector, volumeMode, volumeName, dataSource, etc.) that users may need to configure based on their storage requirements. Using `additionalProperties: true` allows flexibility while still validating the defined fields.

### When to Use `additionalProperties: false` (Default)

Use this (or omit, as it's the default) for objects with well-defined, fixed structures:

```yaml
# @schema
# type: object
# required: true
# @schema
image:
# Only allows: repository, pullPolicy, tag
# Rejects any other properties
```

**Use Case:** Strict validation prevents typos and configuration errors.

---

## Validation Constraints

### Numeric Constraints

#### Port Numbers

```yaml
# @schema
# type: integer
# required: true
# minimum: 1
# maximum: 65535
# @schema
port: 50051
```

**Rationale:**
- `minimum: 1` prevents port 0 (almost always a configuration error in Kubernetes)
- `maximum: 65535` enforces valid port range
- Catches configuration errors early
- **Always use `minimum: 1` for Kubernetes port configurations**

#### Replica Counts

```yaml
# @schema
# type: integer
# required: true
# minimum: 0
# @schema
replicaCount: 2
```

**Rationale:**
- `minimum: 0` allows scaling to zero replicas (useful for dev/testing)
- No maximum - allows any number of replicas

#### Log Levels

```yaml
# @schema
# type: integer
# required: true
# @schema
level: 0
```

**Note:** Omit `minimum`/`maximum` if log level range is implementation-dependent.

---

## Format Specifications

### URI Format

Use `format: uri` for URL fields:

```yaml
# @schema
# type: string
# required: false
# format: uri
# @schema
ingressUrl: https://ingress.eu2.coralogix.com/
```

**Benefits:**
- Validates URL structure
- Catches malformed URLs
- Provides better IDE autocomplete hints

### Other Standard Formats

JSON Schema supports these built-in formats:

- `date-time` - ISO 8601 date-time
- `date` - ISO 8601 date
- `time` - ISO 8601 time
- `email` - Email address
- `hostname` - DNS hostname
- `ipv4` - IPv4 address
- `ipv6` - IPv6 address
- `uri` - URI reference
- `uri-reference` - URI reference (relative or absolute)
- `uuid` - UUID

---

## Pattern Matching

### Kubernetes Resource Quantities

#### CPU Resources

```yaml
# @schema
# type: string
# required: false
# pattern: ^[0-9]+(\.[0-9]+)?m?$
# @schema
cpu: 250m
```

**Pattern Breakdown:**
- `^[0-9]+` - One or more digits
- `(\.[0-9]+)?` - Optional decimal part
- `m?` - Optional 'm' suffix for millicores
- `$` - End of string

**Valid Examples:**
- Millicores: `250m`, `1000m`, `500m`
- Cores: `1`, `0.5`, `2`, `1.5`

**Invalid Examples:** `-1`, `1.5m` (decimal with millicore suffix), `1k`, `abc`

**Best Practice:** Both formats are valid and should be used based on context:
- Use **millicores** (`250m`) for precise small allocations
- Use **cores** (`1`, `0.5`) for simpler whole or fractional core values

#### Memory Resources

```yaml
# @schema
# type: string
# required: false
# pattern: ^[0-9]+(\.[0-9]+)?(Ki|Mi|Gi|Ti|Pi|Ei|k|M|G|T|P|E)?$
# @schema
memory: 2Gi
```

**Pattern Breakdown:**
- `^[0-9]+` - One or more digits
- `(\.[0-9]+)?` - Optional decimal part
- `(Ki|Mi|Gi|Ti|Pi|Ei|k|M|G|T|P|E)?` - Optional unit suffix
    - **Binary units (preferred):** `Ki`, `Mi`, `Gi`, `Ti`, `Pi`, `Ei` (1024-based)
    - **Decimal units:** `k`, `M`, `G`, `T`, `P`, `E` (1000-based)

**Valid Examples:** `2Gi`, `512Mi`, `1.5Gi`, `1000000000` (bytes)

**Invalid Examples:** `-1Gi`, `2GB`, `1.5`, `abc`

**Best Practice:** Prefer binary units (`Ki`, `Mi`, `Gi`) for memory as they're more commonly used in Kubernetes.

### Why Use Patterns Instead of Format?

JSON Schema doesn't have built-in formats for Kubernetes-specific types. Patterns provide:
- Precise validation for domain-specific formats
- Prevention of common mistakes
- Clear error messages when validation fails

---

## Enum Values

### Basic Enum Usage

Use `enum` to restrict values to a specific set:

```yaml
# @schema
# required: true
# enum: [Ignore, Fail]
# @schema
failurePolicy: Ignore
```

**Important:** When using `enum`, **do not specify `type`** - it's automatically inferred.

### Kubernetes-Specific Enums

```yaml
# @schema
# required: true
# enum: [Always, IfNotPresent, Never]
# @schema
pullPolicy: Always
```

**Benefits:**
- Prevents typos (`Allways`, `always`, etc.)
- Provides IDE autocomplete
- Clear validation errors

---

## Documentation Comments

### Comment Placement

Documentation comments must appear **after** the closing `@schema` marker:

```yaml
# @schema
# type: string
# required: true
# @schema
# Image repository
repository: "example.com/image"
```

### Comment Style Guidelines

**Required Rules:**

1. **No type annotations** - Never include type information in comments (e.g., `(string)`, `(integer)`, `(boolean)`)
2. **No `--` prefix** - Do not use Helm-doc style `# --` prefix
3. **Keep descriptive comments** - Always provide meaningful descriptions that explain the purpose, usage, or context of fields
4. **Clear descriptions** - Use concise, meaningful descriptions that add value beyond the field name
5. **Proper capitalization** - Start with a capital letter
6. **No trailing periods** - Omit periods for single-line comments

**Important:** While you should avoid duplicating schema type information (like `(string)` or `(integer)`), you **should always include descriptive comments** that explain what the field does, its purpose, or how it should be used. These comments provide essential context for users of the Helm chart.

**Examples:**

✅ **Correct:**
```yaml
# @schema
# type: string
# required: true
# @schema
# Image repository
repository: "example.com/image"

# @schema
# type: integer
# required: true
# minimum: 0
# maximum: 100
# @schema
# Percentage threshold to limit PVC utilization
threshold: 80

# @schema
# type: string
# required: true
# @schema
# Size by which to expand a PVC that exceeded its disk utilization threshold
# Can be either percentage or resource quantity ("20%"/"5Gi")
expansionSize: "20%"
```

❌ **Incorrect:**
```yaml
# -- (string) Image repository
repository: "example.com/image"

# -- (integer) A percentage threshold
threshold: 80

# (string) The expansion size
expansionSize: "20%"
```

---

## Common Patterns

### Optional Configuration with Defaults

```yaml
# @schema
# type: object
# required: false
# additionalProperties: true
# @schema
pdb:
  # @schema
  # type: integer
  # required: false
  # @schema
  maxUnavailable: 1
```

**Use Case:** Entire section is optional, but if provided, has sensible defaults.

### Required Fields with Defaults

```yaml
# @schema
# type: object
# required: true
# @schema
deployment:
  # @schema
  # type: object
  # required: true
  # @schema
  image:
    # @schema
    # type: string
    # required: true
    # @schema
    repository: "example.com/image"
```

**Use Case:** Critical configuration that must exist in final merged values. Users can override but don't need to specify if defaults are acceptable.

**User experience:**
- User provides minimal overrides: `deployment: { image: { tag: "v2.0" } }`
- Helm merges with defaults: repository comes from defaults, tag from user
- Validation passes: all required fields present in merged result

### Flexible User-Defined Maps

```yaml
# @schema
# type: object
# required: false
# additionalProperties: true
# @schema
nodeSelector: {}
```

**Use Case:** Accepts any key-value pairs user wants to add. Optional field that can be omitted entirely if not needed.

### Validated String with Pattern

```yaml
# @schema
# type: string
# required: true
# pattern: ^[0-9]+(\.[0-9]+)?(Ki|Mi|Gi|Ti|Pi|Ei|k|M|G|T|P|E)?$
# @schema
memory: 2Gi
```

**Use Case:** Ensures string matches specific format (Kubernetes resource quantity).

### Constrained Integers

```yaml
# @schema
# type: integer
# required: true
# minimum: 1
# maximum: 65535
# @schema
port: 8080
```

**Use Case:** Validates numeric ranges (ports, counts, etc.).

---

## Summary Checklist

When adding schema annotations, ensure:

- [ ] `@schema` markers properly opened and closed
- [ ] `type` specified (except for `enum` fields)
- [ ] `required` explicitly set (`true` or `false`)
- [ ] `additionalProperties` set for objects (when needed)
- [ ] Validation constraints added (`minimum`, `maximum`, `pattern`, `enum`)
- [ ] `format` used for standard types (URIs, emails, etc.)
- [ ] Documentation comments placed after closing `@schema`
- [ ] Comments don't duplicate type information
- [ ] Patterns tested with valid and invalid examples

---

## References

- [helm-schema GitHub](https://github.com/dadav/helm-schema)
- [JSON Schema Specification](https://json-schema.org/)
- [Kubernetes Resource Quantities](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
