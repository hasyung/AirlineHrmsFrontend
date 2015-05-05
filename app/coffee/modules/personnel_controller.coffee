
nb = @.nb
app = nb.app
extend = angular.extend
resetForm = nb.resetForm
Modal = nb.Modal



class Route
    @.$inject = ['$stateProvider']

    constructor: (stateProvider) ->
        stateProvider
            .state 'personnel_list', {
                url: '/personnel'
                templateUrl: 'partials/personnel/personnel.html'
                controller: PersonnelCtrl
                controllerAs: 'ctrl'

            }
            .state 'personnel_fresh',{
                url: '/personnel/fresh-list'
                controller: NewEmpsCtrl
                controllerAs: 'ctrl'
                templateUrl: 'partials/personnel/personnel_new_list.html'
            }
            .state 'personnel_review', {
                url: '/personnel/change-review'
                templateUrl: 'partials/personnel/change_review.html'
                controller: ReviewCtrl
                controllerAs: 'ctrl'

            }

class PersonnelCtrl extends nb.Controller

    @.$inject = ['$scope', 'sweet', 'Employee']


    constructor: (@scope, @sweet, @Employee) ->
        @loadInitailData()
        @selectedIndex =  1


        @columnDef = [
            {displayName: '所属部门', name: 'department.name'}
            {
                displayName: '姓名'
                field: 'name'
                pinnedLeft: true
                cellTemplate: '''
                <a class="ui-grid-cell-contents" nb-panel
                    template-url="partials/personnel/info_basic.html"
                    locals="{employee: row.entity}">
                    {{grid.getCellValue(row, col)}}
                </a>'
                '''
            }
            {displayName: '员工编号', field: 'employeeNo'}
            {displayName: '岗位', name: 'position.name'}
            {displayName: '分类', name: 'category.displayName'}
            {displayName: '通道', name: 'channel.displayName'}
            {displayName: '用工性质', name: 'laborRelation.displayName'}
            {displayName: '到岗时间', field: 'joinScalDate'}
        ]
        @constraints = [


        ]
        @filterOptions = {
            name: 'personnel'
            constraintDefs: [
                {
                    name: 'name'
                    displayName: '姓名'
                    type: 'string'
                    placeholder: '姓名'
                }
                {
                    name: 'employee_no'
                    displayName: '员工编号'
                    type: 'string'
                    placeholder: '员工编号'
                }
                {
                    name: 'department_ids'
                    displayName: '机构'
                    type: 'org-search'
                }
            ]
        }




    loadInitailData: ->
        @employees = @Employee.$collection().$fetch()

    search: (tableState) ->
        @employees.$refresh(tableState)

    getExportParams: ->
        @employees
                .filter (emp) -> emp.isSelected
                .map (emp) -> emp.id
                .join(',')

class NewEmpsCtrl extends nb.Controller
    @.$inject = ['$scope', 'Employee', 'Org']
    constructor: (@scope, @Employee, @Org) ->
        @newEmp = {}
        @loadInitailData()

    loadInitailData: ->

        collection_param = {
            predicate: {
                join_scal_date: {
                    from: moment().subtract(1, 'year').format('YYYY-MM-DD')
                    to: moment().format("YYYY-MM-DD")
                }
            }
            sort: {
                join_scal_date: 'desc'
            }
        }
        @employees = @Employee.$collection(collection_param).$fetch()
    regEmployee: (employee)->
        self = @
        @employees.$build(employee).$save().$then ()->
            self.loadInitailData()

    getExportParams: ->
        @employees
                .filter (emp) -> emp.isSelected
                .map (emp) -> emp.id
                .join(',')
    search: (tableState) ->
        tableState = @mergeParams(tableState)
        @employees.$refresh(tableState)
    mergeParams: (tableState)->
        params = {
            predicate: {
                join_scal_date: {
                    from: moment().subtract(1, 'year').format('YYYY-MM-DD')
                    to: moment().format("YYYY-MM-DD")
                }
            }
            sort: {
                join_scal_date: 'desc'
            }
        }
        angular.forEach params, (val, key)->
            if angular.isObject(val)
                angular.forEach val, (nestedVal, nestedKey)->
                    tableState[key][nestedKey] = nestedVal
        return tableState


class ReviewCtrl extends nb.Controller
    @.$inject = ['$scope', 'Change', 'Record', '$mdDialog']
    constructor: (@scope, @Change, @Record, @mdDialog) ->
        @loadInitailData()

    loadInitailData: ->
        # @changes = @Change.$collection().$fetch()
        # @records = @Record.$collection().$fetch()
    searchRecord: (tableState)->
        @records.$refresh(tableState)
    checkChanges: ()->
        params = []
        # '无需审核': 0
        # '待审核': 1
        # '通过': 2
        # '不通过': 3
        checked = _.filter @changes, (item)->
            return item if item.statusCd != "1"
        _.forEach checked, (item)->
            temp = {}
            temp.id = item.id
            temp.status_cd = item.statusCd
            temp.reason = item.reason
            params.push temp
        @changes.checkChanges(params)

class PersonnelSort extends nb.Controller
    @.$inject = ['$scope', 'Org', 'Position', 'Employee', '$http']
    constructor: (@scope, @Org, @Position, @Employee, @http) ->
        @orgLinks = []
        @loadInitailData()

    loadInitailData: ->
        self = @
        @currentOrgs = @Org.$search().$then (data)->
            self.currentOrgs = data.jqTreeful()[0]
            self.orgLinks.push self.currentOrgs

    orgSelectBack: ->
        if @orgLinks.length > 1
            @orgLinks.pop()
            @currentOrgs = @orgLinks[@orgLinks.length-1]

    showChildsOrg: (org)->
        @orgLinks.push(org)
        @currentOrgs = org
    setHeigher: (collection, index, category)->
        return if index == 0 || (!category)
        params = {
            category:category
            current_id: collection[index].id
            target_id:collection[index-1].id
        }
        promise = @changeOrder params
        promise.then ()->
            temp = collection[index]
            collection[index] = collection[index-1]
            collection[index-1] = temp
    setLower: (collection, index, category)->
        return if index >= collection.length-1 || (!category)
        params = {
            category:category
            current_id: collection[index].id
            target_id:collection[index+1].id
        }
        promise = @changeOrder params
        promise.then ()->
            temp = collection[index]
            collection[index] = collection[index+1]
            collection[index+1] = temp

    changeOrder: (params)->
        promise = @http.get '/api/sort', {params:params}
        # promise.then onSuccess

orgMutiPos = ($rootScope)->
    class PersonnelPositions extends nb.Controller
        @.$inject = ['$scope', '$rootScope']
        constructor: (@scope, @rootScope) ->
            @scope.positions = []
            @scope.allOrgs = @rootScope.allOrgs

        addPositions: ->
            @scope.positions.push {
                position_id: ""
                category: ""
            }
        removePosition: (index)->
            @scope.positions.splice index, 1

        setHeigher: (index)->
            return if index == 0
            temp = @scope.positions[index]
            @scope.positions[index] = @scope.positions[index-1]
            @scope.positions[index-1] = temp


    postLink = (elem, attrs, ctrl)->


    return {
        scope: {
            positions: "=ngModel"
        }
        replace: true
        templateUrl: "partials/personnel/muti-positions.tpl.html"
        require: 'ngModel'
        link: postLink
        controller: PersonnelPositions
        controllerAs: "ctrl"
    }

app.directive('orgMutiPos',[orgMutiPos])








app.config(Route)
app.controller('PersonnelSort', PersonnelSort)
