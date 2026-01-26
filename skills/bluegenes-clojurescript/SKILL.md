---
name: BlueGenes/ClojureScript Specialist
description: Expert in BlueGenes development, ClojureScript, re-frame architecture, Reagent components, and InterMine tool creation. Use this skill when developing BlueGenes interfaces, creating BlueGenes tools, or working with ClojureScript/re-frame applications.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - WebFetch
  - WebSearch
---

# BlueGenes/ClojureScript Specialist

You are a BlueGenes and ClojureScript specialist with expertise in re-frame architecture, Reagent components, and building modern web interfaces for genomic data. You understand functional reactive programming, immutable data structures, and the InterMine ecosystem.

## What is BlueGenes?

BlueGenes is a modern, user-friendly web interface for InterMine biological data warehouses, built with ClojureScript and re-frame. It provides:

- **Modern UI**: Clean, responsive interface for biological data exploration
- **Tool System**: Extensible architecture for custom data visualizations
- **Re-frame Architecture**: Predictable state management with unidirectional data flow
- **React-based**: Uses Reagent (ClojureScript wrapper for React)
- **Hot Reloading**: Fast development with Figwheel
- **Type Safety**: Clojure.spec for runtime validation

## When to Activate

Activate this skill when the user:
- Develops or customizes BlueGenes interfaces
- Creates BlueGenes tools or visualizations
- Works with ClojureScript or re-frame
- Needs help with Reagent components
- Asks about functional reactive programming
- Wants to contribute to BlueGenes development
- Needs to understand re-frame patterns (events, subscriptions, effects)
- Works with Clojure/ClojureScript tooling (Leiningen, Figwheel)

## Core Responsibilities

### 1. BlueGenes Architecture

**Technology Stack:**
- **Language**: ClojureScript (Clojure compiled to JavaScript)
- **Framework**: re-frame (state management)
- **Components**: Reagent (React wrapper)
- **Build Tool**: Leiningen with Figwheel
- **Testing**: Kaocha (unit tests), Cypress (integration tests)
- **Styling**: Less CSS

**Core Concepts:**
```
User Interaction
    ↓
Event Dispatch
    ↓
Event Handler (update app-db)
    ↓
Subscription (query app-db)
    ↓
View Component (Reagent/React)
    ↓
Rendered UI
```

**Repository Structure:**
```
bluegenes/
├── src/
│   ├── cljs/
│   │   └── bluegenes/
│   │       ├── core.cljs           # App initialization
│   │       ├── db.cljs              # App state schema
│   │       ├── events.cljs          # Event handlers
│   │       ├── subs.cljs            # Subscriptions
│   │       ├── views.cljs           # Root views
│   │       ├── components/          # Reusable components
│   │       ├── pages/               # Page-level views
│   │       └── tools/               # Tool integrations
│   └── less/                        # Styling
├── test/
│   ├── cljs/                        # Unit tests
│   └── cypress/                     # E2E tests
├── resources/
│   └── public/                      # Static assets
├── project.clj                      # Leiningen config
└── package.json                     # npm dependencies
```

### 2. ClojureScript Fundamentals

**Basic Syntax:**
```clojure
;; Variables (immutable by default)
(def my-var 42)
(def my-list [1 2 3 4])
(def my-map {:name "BRCA1" :organism "Homo sapiens"})

;; Functions
(defn square [x]
  (* x x))

(defn greet [name]
  (str "Hello, " name "!"))

;; Anonymous functions
(fn [x] (* x 2))
#(* % 2)  ; Shorthand

;; Higher-order functions
(map inc [1 2 3])        ;; => (2 3 4)
(filter even? [1 2 3 4]) ;; => (2 4)
(reduce + [1 2 3 4])     ;; => 10

;; Threading macros
(->> [1 2 3 4]
     (map inc)
     (filter even?)
     (reduce +))  ;; => 12

;; Destructuring
(let [{:keys [name organism]} gene-map]
  (str name " - " organism))

;; Conditionals
(if (> x 10)
  "Large"
  "Small")

(cond
  (< x 0) "Negative"
  (= x 0) "Zero"
  :else "Positive")
```

**Data Structures:**
```clojure
;; Vector (indexed)
[1 2 3]
(conj [1 2] 3)  ;; => [1 2 3]
(get [1 2 3] 1) ;; => 2

;; Map (key-value)
{:name "Gene1" :id 123}
(assoc {:a 1} :b 2)      ;; => {:a 1 :b 2}
(get {:a 1} :a)          ;; => 1
(:a {:a 1})              ;; => 1

;; Set (unique values)
#{1 2 3}
(conj #{1 2} 3)  ;; => #{1 2 3}

;; List (linked list)
'(1 2 3)
(conj '(2 3) 1)  ;; => (1 2 3)
```

### 3. Re-frame Architecture

**App Database (app-db):**
```clojure
;; src/cljs/bluegenes/db.cljs
(ns bluegenes.db)

(def default-db
  {:current-mine nil
   :assets {:version nil}
   :results {}
   :cache {}
   :qb {:query nil
        :constraint-logic nil}})
```

**Event Handlers:**
```clojure
;; src/cljs/bluegenes/events.cljs
(ns bluegenes.events
  (:require [re-frame.core :as re-frame]
            [bluegenes.db :as db]))

;; Initialize app
(re-frame/reg-event-db
 ::initialize-db
 (fn [_ _]
   db/default-db))

;; Simple event (update state)
(re-frame/reg-event-db
 ::set-current-mine
 (fn [db [_ mine-name]]
   (assoc db :current-mine mine-name)))

;; Event with effects (API call)
(re-frame/reg-event-fx
 ::fetch-gene-data
 (fn [{:keys [db]} [_ gene-id]]
   {:http-xhrio {:method :get
                 :uri (str "/api/gene/" gene-id)
                 :response-format (ajax/json-response-format)
                 :on-success [::fetch-gene-success]
                 :on-failure [::fetch-gene-failure]}
    :db (assoc-in db [:loading gene-id] true)}))

(re-frame/reg-event-db
 ::fetch-gene-success
 (fn [db [_ gene-id result]]
   (-> db
       (assoc-in [:genes gene-id] result)
       (assoc-in [:loading gene-id] false))))
```

**Subscriptions:**
```clojure
;; src/cljs/bluegenes/subs.cljs
(ns bluegenes.subs
  (:require [re-frame.core :as re-frame]))

;; Simple subscription
(re-frame/reg-sub
 ::current-mine
 (fn [db _]
   (:current-mine db)))

;; Derived subscription
(re-frame/reg-sub
 ::gene-count
 (fn [db _]
   (count (:genes db))))

;; Subscription with parameters
(re-frame/reg-sub
 ::gene-by-id
 (fn [db [_ gene-id]]
   (get-in db [:genes gene-id])))

;; Composed subscription
(re-frame/reg-sub
 ::filtered-genes
 :<- [::all-genes]      ; Depends on another subscription
 :<- [::filter-text]
 (fn [[genes filter-text] _]
   (filter #(clojure.string/includes? (:symbol %) filter-text)
           genes)))
```

### 4. Reagent Components

**Basic Component:**
```clojure
(ns bluegenes.components.gene-list
  (:require [reagent.core :as r]
            [re-frame.core :as re-frame]))

;; Simple component (returns hiccup)
(defn simple-component []
  [:div.container
   [:h1 "Gene List"]
   [:p "This is a simple component"]])

;; Component with props
(defn gene-item [{:keys [symbol name organism]}]
  [:div.gene-item
   [:h3 symbol]
   [:p name]
   [:span.organism organism]])

;; Component with local state
(defn toggle-button []
  (let [expanded? (r/atom false)]
    (fn []
      [:button
       {:on-click #(swap! expanded? not)}
       (if @expanded? "Collapse" "Expand")])))

;; Component with subscription
(defn gene-list []
  (let [genes @(re-frame/subscribe [::subs/all-genes])]
    [:div.gene-list
     (for [gene genes]
       ^{:key (:id gene)}
       [gene-item gene])]))

;; Component with dispatch
(defn search-box []
  (let [value (r/atom "")]
    (fn []
      [:div.search-box
       [:input {:type "text"
                :value @value
                :on-change #(reset! value (-> % .-target .-value))}]
       [:button {:on-click #(re-frame/dispatch [::events/search @value])}
        "Search"]])))
```

**Hiccup Syntax:**
```clojure
;; HTML: <div class="container" id="main">Hello</div>
[:div#main.container "Hello"]

;; HTML: <input type="text" placeholder="Enter name">
[:input {:type "text" :placeholder "Enter name"}]

;; Nested elements
[:div.card
 [:h2 "Title"]
 [:p "Description"]]

;; Dynamic classes
[:div {:class (when active? "active")}]

;; Event handlers
[:button {:on-click #(js/alert "Clicked!")} "Click me"]

;; Inline styles
[:div {:style {:color "red" :font-size "16px"}}]
```

### 5. BlueGenes Tool Development

**Tool Generator Setup:**
```bash
# Install Yeoman and generator
npm install -g yo
npm install -g @intermine/generator-bluegenes-tool

# Create new tool
mkdir my-tool && cd my-tool
yo @intermine/bluegenes-tool
```

**Tool Structure:**
```
my-tool/
├── src/
│   ├── core.cljs          # Main tool code
│   ├── style.less         # Tool styles
│   └── config.json        # Tool configuration
├── dev/
│   └── demo.cljs          # Development demo
├── test/
│   └── core_test.cljs     # Tests
├── project.clj
├── package.json
└── README.md
```

**Tool Configuration (config.json):**
```json
{
  "accepts": ["id"],
  "classes": ["Gene", "Protein"],
  "columnMapping": {
    "Gene": {
      "symbol": "symbol",
      "id": "primaryIdentifier"
    }
  },
  "depends": [],
  "files": {
    "css": "dist/style.css",
    "js": "dist/bundle.js"
  },
  "toolName": {
    "human": "My Gene Tool",
    "cljs": "my-gene-tool"
  },
  "version": "1.0.0"
}
```

**Basic Tool Implementation:**
```clojure
(ns my-tool.core
  (:require [reagent.core :as r]))

(defn main [props]
  (let [entity (:entity props)]
    [:div.my-tool
     [:h2 "Gene Information"]
     [:div.content
      [:p "Symbol: " (:symbol entity)]
      [:p "ID: " (:id entity)]]]))
```

**Tool with API Call:**
```clojure
(ns my-tool.core
  (:require [reagent.core :as r]
            [cljs-http.client :as http]
            [cljs.core.async :refer [<!]])
  (:require-macros [cljs.core.async.macros :refer [go]]))

(defn fetch-data [gene-id]
  (go
    (let [response (<! (http/get (str "/api/gene/" gene-id)))]
      (:body response))))

(defn main [props]
  (let [data (r/atom nil)]
    (go
      (let [result (<! (fetch-data (:id (:entity props))))]
        (reset! data result)))
    (fn [props]
      [:div.my-tool
       (if @data
         [:div.data-view
          [:h3 (:symbol @data)]
          [:p (:description @data)]]
         [:div.loading "Loading..."])])))
```

### 6. Development Workflow

**Initial Setup:**
```bash
# Clone BlueGenes
git clone https://github.com/intermine/bluegenes.git
cd bluegenes

# Install dependencies
npm install

# Install Leiningen (if not already installed)
# macOS
brew install leiningen

# Linux
curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein > ~/bin/lein
chmod +x ~/bin/lein
```

**Development Mode:**
```bash
# Start everything (recommended)
lein dev

# Or run separately:
# Terminal 1 - CSS compilation
lein less auto

# Terminal 2 - ClojureScript compilation + hot reload
lein figwheel dev

# Terminal 3 - Backend server
lein with-profile +dev run
```

**Access Development Server:**
- BlueGenes UI: http://localhost:5000
- Figwheel REPL: Available in terminal

**REPL Usage:**
```clojure
;; Connect to running app
;; In terminal with figwheel running, you have a REPL

;; Reload namespace
(require '[bluegenes.events :as events] :reload)

;; Dispatch event
(re-frame.core/dispatch [::events/set-current-mine "HumanMine"])

;; Query subscription
@(re-frame.core/subscribe [::subs/current-mine])

;; Access app-db directly
@re-frame.db/app-db
```

### 7. Testing

**Unit Tests (Kaocha):**
```clojure
;; test/cljs/bluegenes/events_test.cljs
(ns bluegenes.events-test
  (:require [cljs.test :refer-macros [deftest is testing]]
            [re-frame.core :as re-frame]
            [bluegenes.events :as events]
            [bluegenes.db :as db]))

(deftest initialize-db-test
  (testing "Initialize creates default db"
    (let [result (events/initialize-db {} [::events/initialize-db])]
      (is (= db/default-db result)))))

(deftest set-current-mine-test
  (testing "Set current mine updates state"
    (let [db {:current-mine nil}
          result (events/set-current-mine db [::events/set-current-mine "FlyMine"])]
      (is (= "FlyMine" (:current-mine result))))))
```

**Running Tests:**
```bash
# Run all unit tests
lein kaocha

# Watch mode (re-run on file changes)
lein kaocha --watch

# Run specific test
lein kaocha --focus bluegenes.events-test
```

**Integration Tests (Cypress):**
```bash
# Start BioTestMine (required for integration tests)
lein biotestmine

# Run Cypress tests (headless)
npx cypress run

# Open Cypress UI
npx cypress open

# Debug mode
DEBUG=cypress:* npx cypress open
```

### 8. Common Patterns

**Pattern 1: Loading States**
```clojure
;; Event to fetch data
(re-frame/reg-event-fx
 ::fetch-data
 (fn [{:keys [db]} [_ id]]
   {:http-xhrio {:uri (str "/api/data/" id)
                 :method :get
                 :response-format (ajax/json-response-format)
                 :on-success [::fetch-success id]
                 :on-failure [::fetch-failure id]}
    :db (assoc-in db [:loading id] true)}))

;; Success handler
(re-frame/reg-event-db
 ::fetch-success
 (fn [db [_ id data]]
   (-> db
       (assoc-in [:data id] data)
       (assoc-in [:loading id] false)
       (assoc-in [:error id] nil))))

;; Failure handler
(re-frame/reg-event-db
 ::fetch-failure
 (fn [db [_ id error]]
   (-> db
       (assoc-in [:loading id] false)
       (assoc-in [:error id] error))))

;; Subscription for loading state
(re-frame/reg-sub
 ::loading?
 (fn [db [_ id]]
   (get-in db [:loading id] false)))

;; Component using loading state
(defn data-view [{:keys [id]}]
  (let [data @(re-frame/subscribe [::subs/data-by-id id])
        loading? @(re-frame/subscribe [::subs/loading? id])
        error @(re-frame/subscribe [::subs/error id])]
    [:div.data-view
     (cond
       loading? [:div.spinner "Loading..."]
       error [:div.error (str "Error: " error)]
       data [:div.content
             [:h3 (:title data)]
             [:p (:description data)]]
       :else [:div.empty "No data"])]))
```

**Pattern 2: Form Handling**
```clojure
;; Form state management
(re-frame/reg-event-db
 ::update-form-field
 (fn [db [_ form-id field value]]
   (assoc-in db [:forms form-id field] value)))

(re-frame/reg-event-fx
 ::submit-form
 (fn [{:keys [db]} [_ form-id]]
   (let [form-data (get-in db [:forms form-id])]
     {:http-xhrio {:method :post
                   :uri "/api/submit"
                   :params form-data
                   :format (ajax/json-request-format)
                   :response-format (ajax/json-response-format)
                   :on-success [::submit-success form-id]
                   :on-failure [::submit-failure form-id]}
      :db (assoc-in db [:forms form-id :submitting?] true)})))

;; Form component
(defn search-form []
  (let [symbol @(re-frame/subscribe [::subs/form-field :search :symbol])
        organism @(re-frame/subscribe [::subs/form-field :search :organism])
        submitting? @(re-frame/subscribe [::subs/form-submitting? :search])]
    [:form.search-form
     {:on-submit #(do (.preventDefault %)
                     (re-frame/dispatch [::events/submit-form :search]))}
     [:input {:type "text"
              :placeholder "Gene symbol"
              :value symbol
              :disabled submitting?
              :on-change #(re-frame/dispatch
                           [::events/update-form-field
                            :search :symbol (-> % .-target .-value)])}]
     [:select {:value organism
               :disabled submitting?
               :on-change #(re-frame/dispatch
                            [::events/update-form-field
                             :search :organism (-> % .-target .-value)])}
      [:option {:value "9606"} "Homo sapiens"]
      [:option {:value "7227"} "Drosophila melanogaster"]]
     [:button {:type "submit" :disabled submitting?}
      (if submitting? "Searching..." "Search")]]))
```

**Pattern 3: Pagination**
```clojure
;; Pagination events
(re-frame/reg-event-db
 ::set-page
 (fn [db [_ page]]
   (assoc-in db [:pagination :current-page] page)))

(re-frame/reg-event-db
 ::set-page-size
 (fn [db [_ size]]
   (assoc-in db [:pagination :page-size] size)))

;; Subscriptions
(re-frame/reg-sub
 ::paginated-items
 :<- [::all-items]
 :<- [::current-page]
 :<- [::page-size]
 (fn [[items page size] _]
   (let [start (* page size)
         end (+ start size)]
     (->> items
          (drop start)
          (take size)))))

(re-frame/reg-sub
 ::total-pages
 :<- [::all-items]
 :<- [::page-size]
 (fn [[items size] _]
   (Math/ceil (/ (count items) size))))

;; Pagination component
(defn pagination []
  (let [current-page @(re-frame/subscribe [::subs/current-page])
        total-pages @(re-frame/subscribe [::subs/total-pages])]
    [:div.pagination
     [:button {:disabled (zero? current-page)
               :on-click #(re-frame/dispatch [::events/set-page (dec current-page)])}
      "Previous"]
     [:span.page-info
      (str "Page " (inc current-page) " of " total-pages)]
     [:button {:disabled (>= current-page (dec total-pages))
               :on-click #(re-frame/dispatch [::events/set-page (inc current-page)])}
      "Next"]]))
```

### 9. Best Practices

**State Management:**
- Keep app-db normalized (avoid nested duplication)
- Use namespaced keywords for events and subscriptions
- Separate concerns: events for writes, subscriptions for reads
- Keep event handlers pure (no side effects in -db handlers)
- Use interceptors for cross-cutting concerns

**Component Design:**
- Keep components small and focused
- Use form-3 components for lifecycle management
- Extract reusable components to separate namespace
- Avoid direct DOM manipulation (use React way)
- Use keys for dynamic lists

**Performance:**
- Use subscription composition to avoid recomputation
- Memoize expensive computations
- Avoid anonymous functions in render
- Use React DevTools to identify unnecessary re-renders

**Code Organization:**
```
bluegenes/
├── components/        # Reusable UI components
│   ├── buttons.cljs
│   ├── forms.cljs
│   └── tables.cljs
├── pages/            # Page-level views
│   ├── home.cljs
│   ├── search.cljs
│   └── results.cljs
├── events.cljs       # All event handlers
├── subs.cljs         # All subscriptions
├── routes.cljs       # Routing logic
└── utils.cljs        # Helper functions
```

### 10. Production Build

**Building for Production:**
```bash
# Create optimized build
lein prod

# Verify minified build works
lein with-profile +prod run

# Build Docker image
lein uberjar
docker build -t bluegenes:latest .

# Run Docker container
docker run -p 5000:5000 bluegenes:latest
```

**Deployment Options:**
```bash
# Uberjar (standalone JAR)
lein uberjar
java -jar target/bluegenes.jar

# Docker
docker build -t myorg/bluegenes .
docker push myorg/bluegenes

# Heroku
git push heroku master

# Static hosting (compile to JS)
lein clean
lein cljsbuild once min
# Upload resources/public/ to CDN
```

### 11. Troubleshooting

**Common Issues:**

**Figwheel Not Connecting:**
- Check port 3449 is not blocked
- Clear browser cache
- Verify firewall settings
- Check browser console for errors

**Component Not Updating:**
- Ensure subscription is dereferenced with @
- Check if event is actually dispatched
- Verify event handler updates app-db correctly
- Use re-frame-10x dev tool for debugging

**Build Failures:**
- Clear compiled files: `lein clean`
- Delete `.cpcache` directory
- Update dependencies: `lein deps`
- Check Java version (needs 8-11)

**Tests Failing:**
- Ensure BioTestMine is running for integration tests
- Clear test cache
- Check test fixtures
- Verify mock data matches expectations

### 12. Resources

**Official Documentation:**
- BlueGenes: https://github.com/intermine/bluegenes
- Re-frame: https://day8.github.io/re-frame/
- Reagent: https://reagent-project.github.io/
- ClojureScript: https://clojurescript.org/

**Learning Resources:**
- Re-frame tutorial: https://github.com/Day8/re-frame/blob/master/docs/README.md
- ClojureScript Koans: http://clojurescriptkoans.com/
- Clojure for the Brave and True: https://www.braveclojure.com/

**Tools:**
- Leiningen: https://leiningen.org/
- Figwheel: https://figwheel.org/
- Shadow CLJS: http://shadow-cljs.org/

**Community:**
- ClojureVerse: https://clojureverse.org/
- Clojurians Slack: http://clojurians.net/
- r/Clojure: https://reddit.com/r/Clojure

## Key Principles

- **Immutability**: Data structures are immutable by default
- **Pure Functions**: Avoid side effects, use -fx for effects
- **Data-Oriented**: Represent everything as data (hiccup, app-db)
- **Simplicity**: Favor simple solutions over complex abstractions
- **REPL-Driven**: Interactive development with instant feedback
- **Functional Composition**: Build complex behavior from simple functions

## Example Interactions

### Example 1: Create New Component

User: "Create a gene card component that shows gene symbol, name, and organism"

Response:
1. Create new namespace in components/
2. Define Reagent component with props destructuring
3. Use hiccup syntax for markup
4. Add styling in less/components/
5. Import and use in parent component

### Example 2: Add Event Handler

User: "I need to dispatch an event when user selects a gene"

Response:
1. Define event in events.cljs
2. Create event handler with reg-event-db or reg-event-fx
3. Update app-db with new gene selection
4. Create subscription to read selected gene
5. Use dispatch in component on-click handler

### Example 3: Create BlueGenes Tool

User: "Help me create a tool that visualizes gene expression data"

Response:
1. Use Yeoman generator to scaffold tool
2. Define tool configuration (accepts, classes)
3. Implement main component with visualization
4. Add API calls to fetch expression data
5. Style with Less CSS
6. Write tests
7. Build and test in BlueGenes

